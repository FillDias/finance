# Waterfall do saldo acumulado mês a mês (padrão ECharts: uma série "base"
# invisível empilhada com uma série "delta" visível), barras vermelhas nos
# meses de saldo negativo, com anotação no mês de maior e menor saldo.
class GraficoSaldoAcumuladoQuery < ApplicationQuery
  def initialize(meses: 6)
    @meses = meses
  end

  def call
    linhas = montar_linhas

    {
      tooltip: { trigger: "axis", axisPointer: { type: "shadow" } },
      xAxis: { type: "category", data: linhas.map { |linha| linha[:mes].strftime("%m/%Y") } },
      yAxis: { type: "value" },
      series: [
        { name: "Base", type: "bar", stack: "saldo", itemStyle: { color: "transparent" }, silent: true, tooltip: { show: false }, data: linhas.map { |linha| linha[:base] } },
        {
          name: "Saldo do mês", type: "bar", stack: "saldo",
          data: linhas.map { |linha| barra(linha) },
          markPoint: pontos_extremos(linhas)
        }
      ]
    }
  end

  private

  def montar_linhas
    serie = SerieMensal.call(meses: @meses) { |mes| SaldoDoMesQuery.call(mes: mes) }
    acumulado = 0.to_d

    serie.map do |item|
      inicio = acumulado
      acumulado += item[:valor]
      { mes: item[:mes], valor: item[:valor], base: [ inicio, acumulado ].min, fim: acumulado }
    end
  end

  def barra(linha)
    cor = linha[:valor].negative? ? PaletaGrafico::NEGATIVO : PaletaGrafico::POSITIVO
    { value: linha[:valor].abs, itemStyle: { color: cor } }
  end

  def pontos_extremos(linhas)
    return { data: [] } if linhas.empty?

    maior = linhas.max_by { |linha| linha[:valor] }
    menor = linhas.min_by { |linha| linha[:valor] }

    {
      data: [
        { name: "Maior saldo", coord: [ linhas.index(maior), maior[:fim] ], value: FormatadorMoeda.para(maior[:valor]), itemStyle: { color: PaletaGrafico::POSITIVO } },
        { name: "Menor saldo", coord: [ linhas.index(menor), menor[:fim] ], value: FormatadorMoeda.para(menor[:valor]), itemStyle: { color: PaletaGrafico::NEGATIVO } }
      ]
    }
  end
end
