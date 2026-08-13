# Barras horizontais com gradiente, maior gasto no topo, valor anotado no
# final da barra. Tooltip mostra a composição Despesa + Compras no cartão,
# e a comparação com o mês anterior e com o mesmo mês do ano passado
# (quando há dado pra comparar).
class GraficoGastoPorCategoriaQuery < ApplicationQuery
  def initialize(mes: Date.current, categoria_id: nil, cartao_id: nil)
    @mes = mes.to_date.beginning_of_month
    @categoria_id = categoria_id
    @cartao_id = cartao_id
  end

  def call
    # invertido: o ECharts desenha a categoria do índice 0 embaixo, então
    # pra "maior no topo" a lista (já ordenada do maior pro menor) precisa
    # ser lida de trás pra frente.
    itens = GastoPorCategoriaQuery.call(mes: @mes, categoria_id: @categoria_id, cartao_id: @cartao_id).reverse

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
    texto + comparacoes(item)
  end

  def comparacoes(item)
    texto = ""
    texto += linha_comparacao("Mês anterior", valor_da_categoria(item[:categoria_id], @mes - 1.month))
    texto += linha_comparacao("Mesmo mês, ano passado", valor_da_categoria(item[:categoria_id], @mes - 1.year))
    texto
  end

  def valor_da_categoria(categoria_id, mes)
    GastoPorCategoriaQuery.call(mes: mes, cartao_id: @cartao_id).find { |item| item[:categoria_id] == categoria_id }&.dig(:valor)
  end

  def linha_comparacao(rotulo, valor)
    return "" if valor.nil?

    "<br/>#{rotulo}: #{FormatadorMoeda.para(valor)}"
  end
end
