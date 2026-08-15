# Linha/área com Entradas e Saídas dos últimos 6 meses, mais uma projeção
# tracejada dos próximos 3 (média simples dos últimos 3 meses reais — mesma
# filosofia "sem compounding" usada pros cálculos de rendimento do app,
# aplicada aqui por não haver convenção de séries temporais mais sofisticada
# no projeto). Quando há dado do mesmo mês no ano anterior, uma markLine
# pontilhada marca esse valor pra comparação ano a ano.
class GraficoEntradasVsSaidasQuery < ApplicationQuery
  MESES_HISTORICO = 6
  MESES_PROJECAO = 3

  def call
    meses_reais = (MESES_HISTORICO - 1).downto(0).map { |offset| (Date.current - offset.months).beginning_of_month }
    meses_projetados = (1..MESES_PROJECAO).map { |offset| Date.current.beginning_of_month + offset.months }

    entradas_reais = meses_reais.map { |mes| EntradasDoMesQuery.call(mes: mes) }
    saidas_reais = meses_reais.map { |mes| SaidasDoMesQuery.call(mes: mes) }

    {
      tooltip: { trigger: "axis" },
      legend: {},
      xAxis: { type: "category", data: (meses_reais + meses_projetados).map { |mes| mes.strftime("%m/%Y") } },
      yAxis: { type: "value" },
      series: [
        *serie_com_projecao("Entradas", entradas_reais, PaletaGrafico::POSITIVO, comparacao_anual_entradas),
        *serie_com_projecao("Saídas", saidas_reais, PaletaGrafico::NEGATIVO, comparacao_anual_saidas)
      ]
    }
  end

  private

  def comparacao_anual_entradas
    EntradasDoMesQuery.call(mes: Date.current.beginning_of_month - 1.year)
  end

  def comparacao_anual_saidas
    SaidasDoMesQuery.call(mes: Date.current.beginning_of_month - 1.year)
  end

  # Média simples dos últimos 3 meses reais, repetida pros meses projetados.
  def projetar(valores)
    base = valores.last(3)
    media = base.sum / base.size.to_d
    Array.new(MESES_PROJECAO, media)
  end

  # Duas séries por métrica: a "real" some (nil) nos meses futuros, a
  # "projeção" some nos meses passados e repete o último valor real no
  # ponto de virada, pra a linha tracejada conectar sem buraco visual.
  def serie_com_projecao(nome, reais, cor, valor_ano_anterior)
    projetados = projetar(reais)
    preenchimento_passado = Array.new(reais.size - 1, nil)
    preenchimento_futuro = Array.new(projetados.size, nil)

    [
      {
        name: nome, type: "line", data: reais + preenchimento_futuro, color: cor, areaStyle: { opacity: 0.1 },
        # position/distance evitam que o rótulo do marcador de máximo/mínimo
        # sobreponha a própria linha ou o marcador da outra série.
        markPoint: {
          symbolSize: 46,
          label: { position: "top", distance: 10 },
          data: [ { type: "max", name: "Máximo" }, { type: "min", name: "Mínimo" } ]
        },
        **marklines_comparacao_anual(nome, valor_ano_anterior)
      },
      {
        name: "#{nome} (projeção)", type: "line", data: preenchimento_passado + [ reais.last ] + projetados,
        color: cor, lineStyle: { type: "dashed" }, showSymbol: false, legendHoverLink: false
      }
    ]
  end

  def marklines_comparacao_anual(nome, valor_ano_anterior)
    return {} unless valor_ano_anterior.positive?

    { markLine: { symbol: "none", lineStyle: { type: "dotted" }, data: [ { yAxis: valor_ano_anterior, name: "#{nome}, mesmo mês ano passado" } ] } }
  end
end
