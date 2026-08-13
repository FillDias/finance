# Quanto de Obrigação (qualquer origem, qualquer status) venceu num mês —
# uma foto do fluxo, diferente de ObrigacoesEmAbertoQuery (foto do saldo em
# aberto agora). Ver GraficoSparklineObrigacoesEmAbertoQuery pra mais
# contexto sobre por que Obrigações em aberto não tem como ser recalculado
# retroativamente.
class ValorVencidoNoMesQuery < ApplicationQuery
  def initialize(mes: Date.current)
    @mes = mes.to_date.beginning_of_month
  end

  def call
    ObrigacoesQuery.call(data_inicio: @mes, data_fim: @mes.end_of_month).sum(&:valor)
  end
end
