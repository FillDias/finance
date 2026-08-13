# Rosca com uma fatia por Cartão, sombreada dentro do gradiente de azul do
# guia de design (mais escuro = mais dívida). Tooltip por fatia mostra a
# composição (Saldo Herdado + parcelas), não só o total.
class GraficoDividaPorCartaoQuery < ApplicationQuery
  def call
    itens = DividaPorCartaoQuery.call

    {
      tooltip: { trigger: "item" },
      series: [
        {
          type: "pie",
          radius: [ "40%", "70%" ],
          label: { formatter: "{b}\n{d}%" },
          data: itens.each_with_index.map { |item, indice| fatia(item, indice, itens.size) }
        }
      ]
    }
  end

  private

  def fatia(item, indice, total)
    {
      name: item[:cartao],
      value: item[:valor],
      chave: item[:cartao_id],
      itemStyle: { color: PaletaGrafico.interpolar_azul(indice, total) },
      tooltip: { formatter: composicao(item) }
    }
  end

  def composicao(item)
    "#{item[:cartao]}: #{FormatadorMoeda.para(item[:valor])}<br/>" \
      "Saldo herdado: #{FormatadorMoeda.para(item[:saldo_herdado])}<br/>" \
      "Parcelas em aberto: #{FormatadorMoeda.para(item[:parcelas])}"
  end
end
