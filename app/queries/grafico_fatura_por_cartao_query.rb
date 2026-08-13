# Mesma forma do gráfico de Gasto por Categoria (barras horizontais com
# gradiente, ranking do maior pro menor), aplicada à fatura de cada Cartão
# no mês atual.
class GraficoFaturaPorCartaoQuery < ApplicationQuery
  def initialize(mes: Date.current)
    @mes = mes
  end

  def call
    itens = FaturaPorCartaoQuery.call(mes: @mes).reverse

    {
      tooltip: { trigger: "item" },
      grid: { left: 120, right: 80 },
      xAxis: { type: "value" },
      yAxis: { type: "category", data: itens.map { |item| item[:cartao] } },
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
    { value: item[:valor], tooltip: { formatter: composicao(item) } }
  end

  def composicao(item)
    "#{item[:cartao]}: #{FormatadorMoeda.para(item[:valor])}<br/>" \
      "Saldo herdado: #{FormatadorMoeda.para(item[:saldo_herdado])}<br/>" \
      "Parcelas: #{FormatadorMoeda.para(item[:parcelas])}"
  end
end
