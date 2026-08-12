# Demonstra a convenção do ticket #16 de ponta a ponta: uma query prepara
# a opção do ECharts já pronta, a view só serializa como JSON, e o
# Stimulus chart_controller.js instancia o gráfico sem saber nada do
# domínio. Não é um gráfico de produto — os gráficos reais chegam nos
# tickets do Painel/Investimentos, reaproveitando essa mesma convenção.
class GraficoExemploQuery < ApplicationQuery
  def initialize(ano: Date.current.year)
    @ano = ano
  end

  def call
    dados = TotalDeRendaPorFonte.call(ano: @ano)

    {
      title: { text: "Renda por fonte em #{@ano} (exemplo do chart_controller)" },
      tooltip: {},
      xAxis: { type: "category", data: dados.keys },
      yAxis: { type: "value" },
      series: [ { type: "bar", data: dados.values } ]
    }
  end
end
