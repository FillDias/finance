# DividaTotalQuery é uma foto do agora (Obrigações ainda não pagas) — não
# dá pra recalcular retroativamente o que estava em aberto em meses
# passados sem um histórico de auditoria que o sistema não guarda. Como
# aproximação honesta, a tendência aqui mostra quanto de Obrigação
# *venceu* em cada um dos últimos meses (todas as origens, independente
# de status), não o saldo em aberto naquele momento.
class GraficoSparklineDividaTotalQuery < ApplicationQuery
  def initialize(meses: 6)
    @meses = meses
  end

  def call
    inicio = (@meses - 1).months.ago.to_date.beginning_of_month
    fim = Date.current.end_of_month
    por_mes = ObrigacoesQuery.call(data_inicio: inicio, data_fim: fim)
                              .group_by { |obrigacao| obrigacao.vencimento.beginning_of_month }
                              .transform_values { |itens| itens.sum(&:valor) }

    valores = (0...@meses).map { |offset| por_mes[(inicio + offset.months)] || 0.to_d }

    SparklineOption.para(valores)
  end
end
