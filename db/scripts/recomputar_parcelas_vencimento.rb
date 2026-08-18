# Corrige data_vencimento das Parcelas de Compras calculadas com a versão
# anterior de GerarParcelas, que só resolvia em qual mês a compra fecha
# (Etapa 1) e assumia — errado — que o vencimento cai sempre nesse mesmo
# mês. Quando dia_vencimento < dia_fechamento (o caso mais comum: fecha
# no fim do mês, vence no começo do mês seguinte), o vencimento real é um
# mês depois do que foi gravado.
#
# Em vez de tentar caracterizar exatamente quais Compras foram afetadas,
# recalcula TODAS as parcelas ainda pendentes de toda Compra (de todo
# Perfil) com a lógica atual (já corrigida) e corrige qualquer
# divergência — cobre esse bug, o de fechamento (dia da compra ==
# dia_fechamento, já corrigido antes) e qualquer combinação dos dois na
# mesma Compra. Só recalcula parcelas ainda pendentes; as já pagas
# refletem o que realmente aconteceu e ficam como estão.
#
# Roda perfil por perfil (via Current.perfil) pra reaproveitar as
# associações normais (compra.cartao, compra.parcelas) sem precisar de
# .unscoped em cada uma — ver ADR 0007.
#
# Por padrão roda em modo dry-run: lista o que mudaria, sem salvar nada.
# Pra aplicar de verdade:
#   APLICAR=1 bin/rails runner db/scripts/recomputar_parcelas_vencimento.rb
#
# Dry-run (padrão):
#   bin/rails runner db/scripts/recomputar_parcelas_vencimento.rb

aplicar = ENV["APLICAR"] == "1"

mudancas = []

ActiveRecord::Base.transaction do
  Perfil.find_each do |perfil|
    Current.perfil = perfil

    Compra.includes(:cartao).find_each do |compra|
      recalculadas = GerarParcelas.call(
        valor_total: compra.valor_total, numero_parcelas: compra.numero_parcelas, data_compra: compra.data_compra,
        dia_fechamento: compra.cartao.dia_fechamento, dia_vencimento: compra.cartao.dia_vencimento
      ).valor

      compra.parcelas.order(:data_vencimento).each_with_index do |parcela, indice|
        novo_vencimento = recalculadas[indice][:data_vencimento]
        next if !parcela.pendente? || parcela.data_vencimento == novo_vencimento

        mudancas << {
          perfil: perfil.nome, cartao: compra.cartao.nome, compra_id: compra.id, compra_data: compra.data_compra,
          parcela_id: parcela.id, valor: parcela.valor, vencimento_antigo: parcela.data_vencimento, vencimento_novo: novo_vencimento
        }

        parcela.update!(data_vencimento: novo_vencimento) if aplicar
      end
    end
  end

  Current.reset
  raise ActiveRecord::Rollback unless aplicar
end

puts "Modo: #{aplicar ? "APLICANDO" : "DRY-RUN (nada foi salvo)"}"
puts "Parcelas #{aplicar ? "corrigidas" : "que seriam corrigidas"}: #{mudancas.size}"
puts

mudancas.each do |m|
  linha = "Perfil #{m[:perfil]} | Cartão #{m[:cartao]} | Compra ##{m[:compra_id]} (feita em #{m[:compra_data].strftime('%d/%m/%Y')}) | " \
          "Parcela ##{m[:parcela_id]} | R$ #{format('%.2f', m[:valor])} | " \
          "#{m[:vencimento_antigo].strftime('%d/%m/%Y')} -> #{m[:vencimento_novo].strftime('%d/%m/%Y')}"
  puts linha
end
