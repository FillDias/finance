# Opção do ECharts compartilhada por todo sparkline do app: linha
# minúscula sem eixos, com marcador verde no maior valor e vermelho no
# menor (ver docs/design-visual.md).
module SparklineOption
  def self.para(valores)
    {
      xAxis: { type: "category", show: false, data: valores.each_index.to_a },
      yAxis: { type: "value", show: false },
      grid: { left: 0, right: 0, top: 4, bottom: 0 },
      series: [
        {
          type: "line",
          data: valores,
          symbol: "none",
          lineStyle: { width: 2, color: PaletaGrafico::CABECALHO_FUNDO },
          markPoint: {
            symbolSize: 6,
            label: { show: false },
            data: [
              { type: "max", itemStyle: { color: PaletaGrafico::POSITIVO } },
              { type: "min", itemStyle: { color: PaletaGrafico::NEGATIVO } }
            ]
          }
        }
      ]
    }
  end
end
