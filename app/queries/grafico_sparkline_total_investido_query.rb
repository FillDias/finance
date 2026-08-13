# Sparkline pro KPI "Total investido": linha minúscula sem eixos, com
# marcador verde no maior valor e vermelho no menor (ver docs/design-visual.md).
class GraficoSparklineTotalInvestidoQuery < ApplicationQuery
  def initialize(meses: 12)
    @meses = meses
  end

  def call
    valores = EvolucaoAportesQuery.call(meses: @meses).map { |item| item[:acumulado] }

    {
      xAxis: { type: "category", show: false, data: valores.each_index.to_a },
      yAxis: { type: "value", show: false },
      grid: { left: 0, right: 0, top: 4, bottom: 0 },
      series: [
        {
          type: "line",
          data: valores,
          symbol: "none",
          lineStyle: { width: 2, color: "#2d5fae" },
          markPoint: {
            symbolSize: 6,
            label: { show: false },
            data: [
              { type: "max", itemStyle: { color: "#1a7f4b" } },
              { type: "min", itemStyle: { color: "#c0392b" } }
            ]
          }
        }
      ]
    }
  end
end
