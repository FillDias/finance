# Barras verticais empilhadas, uma série por fonte de Renda, nos últimos N
# meses.
class GraficoEntradasPorFonteQuery < ApplicationQuery
  def initialize(meses: 6)
    @meses = meses
  end

  def call
    itens = EntradasPorFonteQuery.call(meses: @meses)
    meses = (@meses - 1).downto(0).map { |offset| (Date.current - offset.months).beginning_of_month }
    fontes = itens.map { |item| item[:fonte] }.uniq.sort

    {
      tooltip: { trigger: "axis", axisPointer: { type: "shadow" } },
      legend: { data: fontes },
      xAxis: { type: "category", data: meses.map { |mes| mes.strftime("%m/%Y") } },
      yAxis: { type: "value" },
      series: fontes.map { |fonte| serie(fonte, meses, itens) }
    }
  end

  private

  def serie(fonte, meses, itens)
    valores = meses.map { |mes| itens.find { |item| item[:fonte] == fonte && item[:mes] == mes }&.dig(:valor) || 0 }
    { name: fonte, type: "bar", stack: "entradas", data: valores }
  end
end
