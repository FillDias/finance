class GraficoDistribuicaoPorTipoQuery < ApplicationQuery
  def call
    distribuicao = DistribuicaoPorTipoQuery.call

    {
      title: { text: "Distribuição por tipo" },
      tooltip: { trigger: "item" },
      series: [
        {
          type: "pie",
          radius: [ "40%", "70%" ],
          data: distribuicao.map { |tipo, valor| { name: tipo, value: valor } }
        }
      ]
    }
  end
end
