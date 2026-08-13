class GraficoEvolucaoAportesQuery < ApplicationQuery
  def initialize(meses: 12)
    @meses = meses
  end

  def call
    serie = EvolucaoAportesQuery.call(meses: @meses)

    {
      title: { text: "Evolução dos aportes" },
      tooltip: { trigger: "axis" },
      xAxis: { type: "category", data: serie.map { |item| item[:mes].strftime("%m/%Y") } },
      yAxis: { type: "value" },
      series: [
        { name: "Acumulado", type: "line", areaStyle: {}, data: serie.map { |item| item[:acumulado] } }
      ]
    }
  end
end
