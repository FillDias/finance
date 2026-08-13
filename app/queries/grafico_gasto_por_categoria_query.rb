# Barras horizontais com gradiente, maior gasto no topo, valor anotado no
# final da barra. Tooltip mostra a composição Despesa + Compras no cartão.
class GraficoGastoPorCategoriaQuery < ApplicationQuery
  def initialize(mes: Date.current)
    @mes = mes
  end

  def call
    # invertido: o ECharts desenha a categoria do índice 0 embaixo, então
    # pra "maior no topo" a lista (já ordenada do maior pro menor) precisa
    # ser lida de trás pra frente.
    itens = GastoPorCategoriaQuery.call(mes: @mes).reverse

    {
      tooltip: { trigger: "item" },
      grid: { left: 140, right: 80 },
      xAxis: { type: "value" },
      yAxis: { type: "category", data: itens.map { |item| item[:categoria] } },
      series: [
        {
          type: "bar",
          itemStyle: { color: PaletaGrafico.gradiente_linear },
          label: { show: true, position: "right", formatter: "{c}" },
          data: itens.map { |item| barra(item) }
        }
      ]
    }
  end

  private

  def barra(item)
    { value: item[:valor], chave: item[:categoria_id], tooltip: { formatter: composicao(item) } }
  end

  def composicao(item)
    texto = "#{item[:categoria]}: #{FormatadorMoeda.para(item[:valor])}<br/>" \
      "Despesas: #{FormatadorMoeda.para(item[:despesas])}"
    texto += "<br/>Compras no cartão: #{FormatadorMoeda.para(item[:compras])} (#{item[:compras_qtd]})" if item[:compras].positive?
    texto
  end
end
