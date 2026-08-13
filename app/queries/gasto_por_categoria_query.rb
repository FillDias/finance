# Soma Despesa + Compra-com-categoria (ver SaidasDoMesQuery) agrupado por
# categoria, do maior gasto pro menor.
class GastoPorCategoriaQuery < ApplicationQuery
  def initialize(mes: Date.current)
    @mes = mes.to_date.beginning_of_month
  end

  def call
    periodo = @mes..@mes.end_of_month
    despesas = Despesa.where(data: periodo).group(:categoria_id).sum(:valor)
    compras_relacao = Compra.where(data_compra: periodo).where.not(categoria_id: nil)
    compras = compras_relacao.group(:categoria_id).sum(:valor_total)
    compras_qtd = compras_relacao.group(:categoria_id).count

    ids = despesas.keys | compras.keys
    nomes = Categoria.where(id: ids).pluck(:id, :nome).to_h

    ids.map do |id|
      valor_despesas = despesas.fetch(id, 0)
      valor_compras = compras.fetch(id, 0)
      {
        categoria_id: id, categoria: nomes.fetch(id), valor: valor_despesas + valor_compras,
        despesas: valor_despesas, compras: valor_compras, compras_qtd: compras_qtd.fetch(id, 0)
      }
    end.sort_by { |item| -item[:valor] }
  end
end
