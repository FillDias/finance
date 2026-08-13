class GraficoSparklineTotalInvestidoQuery < ApplicationQuery
  def initialize(meses: 12)
    @meses = meses
  end

  def call
    # somente_ativos: true — precisa terminar no mesmo número do KPI
    # "Total investido" ao lado (TotalInvestidoQuery, ativo-only).
    valores = EvolucaoAportesQuery.call(meses: @meses, somente_ativos: true).map { |item| item[:acumulado] }

    SparklineOption.para(valores)
  end
end
