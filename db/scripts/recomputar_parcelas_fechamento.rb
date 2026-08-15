# Corrige data_vencimento das Parcelas de Compras feitas exatamente no dia
# de fechamento do Cartão — GerarParcelas tinha um bug de limite (usava
# `<=` em vez de `<`) que jogava essas parcelas um mês adiantado. Só
# recalcula parcelas ainda pendentes; as já pagas refletem o que realmente
# aconteceu e ficam como estão.
#
# Por padrão roda em modo dry-run: lista o que mudaria, sem salvar nada.
# Pra aplicar de verdade:
#   APLICAR=1 bin/rails runner db/scripts/recomputar_parcelas_fechamento.rb
#
# Dry-run (padrão):
#   bin/rails runner db/scripts/recomputar_parcelas_fechamento.rb

aplicar = ENV["APLICAR"] == "1"

afetadas = Compra.includes(:cartao).select { |compra| compra.data_compra.day == compra.cartao.dia_fechamento }
mudancas = []

ActiveRecord::Base.transaction do
  afetadas.each do |compra|
    recalculadas = GerarParcelas.call(
      valor_total: compra.valor_total, numero_parcelas: compra.numero_parcelas, data_compra: compra.data_compra,
      dia_fechamento: compra.cartao.dia_fechamento, dia_vencimento: compra.cartao.dia_vencimento
    ).valor

    compra.parcelas.order(:data_vencimento).each_with_index do |parcela, indice|
      novo_vencimento = recalculadas[indice][:data_vencimento]
      next if !parcela.pendente? || parcela.data_vencimento == novo_vencimento

      mudancas << {
        cartao: compra.cartao.nome, compra_id: compra.id, compra_data: compra.data_compra, parcela_id: parcela.id,
        valor: parcela.valor, vencimento_antigo: parcela.data_vencimento, vencimento_novo: novo_vencimento
      }

      parcela.update!(data_vencimento: novo_vencimento) if aplicar
    end
  end

  raise ActiveRecord::Rollback unless aplicar
end

puts "Modo: #{aplicar ? "APLICANDO" : "DRY-RUN (nada foi salvo)"}"
puts "Compras afetadas: #{afetadas.size}. Parcelas #{aplicar ? "corrigidas" : "que seriam corrigidas"}: #{mudancas.size}."
puts

mudancas.each do |m|
  linha = "Cartão #{m[:cartao]} | Compra ##{m[:compra_id]} (feita em #{m[:compra_data].strftime('%d/%m/%Y')}) | " \
          "Parcela ##{m[:parcela_id]} | R$ #{format('%.2f', m[:valor])} | " \
          "#{m[:vencimento_antigo].strftime('%d/%m/%Y')} -> #{m[:vencimento_novo].strftime('%d/%m/%Y')}"
  puts linha
end
