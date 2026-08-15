# Corrige data_vencimento das Parcelas de Compras feitas exatamente no dia
# de fechamento do Cartão — GerarParcelas tinha um bug de limite (usava
# `<=` em vez de `<`) que jogava essas parcelas um mês adiantado. Só
# recalcula parcelas ainda pendentes; as já pagas refletem o que realmente
# aconteceu e ficam como estão.
#
# Rodar com: bin/rails runner db/scripts/recomputar_parcelas_fechamento.rb

afetadas = Compra.includes(:cartao).select { |compra| compra.data_compra.day == compra.cartao.dia_fechamento }
total_atualizadas = 0

ActiveRecord::Base.transaction do
  afetadas.each do |compra|
    recalculadas = GerarParcelas.call(
      valor_total: compra.valor_total, numero_parcelas: compra.numero_parcelas, data_compra: compra.data_compra,
      dia_fechamento: compra.cartao.dia_fechamento, dia_vencimento: compra.cartao.dia_vencimento
    ).valor

    compra.parcelas.order(:data_vencimento).each_with_index do |parcela, indice|
      novo_vencimento = recalculadas[indice][:data_vencimento]
      next if !parcela.pendente? || parcela.data_vencimento == novo_vencimento

      parcela.update!(data_vencimento: novo_vencimento)
      total_atualizadas += 1
    end
  end
end

puts "Compras afetadas: #{afetadas.size}. Parcelas corrigidas: #{total_atualizadas}."
