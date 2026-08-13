# DividaTotalQuery é uma foto do agora (Obrigações ainda não pagas) — não
# dá pra recalcular retroativamente o que estava em aberto em meses
# passados sem um histórico de auditoria que o sistema não guarda. Como
# aproximação honesta, a tendência aqui mostra quanto de Obrigação
# *venceu* em cada um dos últimos meses (ver ValorVencidoNoMesQuery), não o
# saldo em aberto naquele momento.
class GraficoSparklineDividaTotalQuery < ApplicationQuery
  def initialize(meses: 6)
    @meses = meses
  end

  def call
    valores = SerieMensal.call(meses: @meses) { |mes| ValorVencidoNoMesQuery.call(mes: mes) }.map { |item| item[:valor] }

    SparklineOption.para(valores)
  end
end
