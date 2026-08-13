# Quanto de Obrigação (qualquer origem, qualquer status) venceu num mês —
# uma foto do fluxo, diferente de DividaTotalQuery (foto do saldo em aberto
# agora). Ver GraficoSparklineDividaTotalQuery pra mais contexto sobre por
# que Dívida Total não tem como ser recalculada retroativamente.
class ValorVencidoNoMesQuery < ApplicationQuery
  def initialize(mes: Date.current)
    @mes = mes.to_date.beginning_of_month
  end

  def call
    ObrigacoesQuery.call(data_inicio: @mes, data_fim: @mes.end_of_month).sum(&:valor)
  end
end
