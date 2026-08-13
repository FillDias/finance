# Soma de todas as Obrigações ainda não pagas (pendentes ou atrasadas),
# como estão hoje — não é um total "do mês", é um retrato do momento atual.
# ObrigacoesQuery já nunca retorna itens pagos (cada origem filtra isso na
# própria consulta), então soma tudo o que ela devolve, sem filtro extra.
class ObrigacoesEmAbertoQuery < ApplicationQuery
  def call
    ObrigacoesQuery.call.sum(&:valor)
  end
end
