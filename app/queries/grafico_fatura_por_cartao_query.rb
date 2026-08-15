# Mesma forma do gráfico de Gasto por Categoria (barras horizontais com
# gradiente, ranking do maior pro menor, comparação com mês anterior e
# mesmo mês do ano passado no tooltip), aplicada à fatura de cada Cartão.
class GraficoFaturaPorCartaoQuery < ApplicationQuery
  def initialize(mes: Date.current, cartao_id: nil)
    @mes = mes.to_date.beginning_of_month
    @cartao_id = cartao_id
  end

  def call
    itens = FaturaPorCartaoQuery.call(mes: @mes, cartao_id: @cartao_id).reverse

    {
      tooltip: { trigger: "item" },
      grid: { left: 16, right: 80, containLabel: true },
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
    texto = "#{item[:cartao]}: #{FormatadorMoeda.para(item[:valor])}<br/>" \
      "Saldo herdado: #{FormatadorMoeda.para(item[:saldo_herdado])}<br/>" \
      "Parcelas: #{FormatadorMoeda.para(item[:parcelas])}"
    texto += linha_comparacao("Mês anterior", valor_do_cartao(item[:cartao_id], @mes - 1.month))
    texto += linha_comparacao("Mesmo mês, ano passado", valor_do_cartao(item[:cartao_id], @mes - 1.year))
    texto
  end

  def valor_do_cartao(cartao_id, mes)
    FaturaPorCartaoQuery.call(mes: mes, cartao_id: @cartao_id).find { |item| item[:cartao_id] == cartao_id }&.dig(:valor)
  end

  def linha_comparacao(rotulo, valor)
    return "" if valor.nil?

    "<br/>#{rotulo}: #{FormatadorMoeda.para(valor)}"
  end
end
