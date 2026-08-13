# Soma Despesa + Compra-com-categoria (ver SaidasDoMesQuery) agrupado por
# categoria, do maior gasto pro menor. categoria_id/cartao_id são os
# mesmos filtros do topo do Painel — cartao_id restringe a Compra e exclui
# Despesa, mesma regra de SaidasDoMesQuery.
class GastoPorCategoriaQuery < ApplicationQuery
  def initialize(mes: Date.current, categoria_id: nil, cartao_id: nil)
    @mes = mes.to_date.beginning_of_month
    @categoria_id = categoria_id
    @cartao_id = cartao_id
  end

  def call
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

  private

  def periodo
    @mes..@mes.end_of_month
  end

  def despesas
    return {} if @cartao_id.present?

    @despesas ||= despesas_relacao.group(:categoria_id).sum(:valor)
  end

  def despesas_relacao
    relacao = Despesa.where(data: periodo)
    relacao = relacao.where(categoria_id: @categoria_id) if @categoria_id.present?
    relacao
  end

  def compras_relacao
    relacao = Compra.where(data_compra: periodo).where.not(categoria_id: nil)
    relacao = relacao.where(categoria_id: @categoria_id) if @categoria_id.present?
    relacao = relacao.where(cartao_id: @cartao_id) if @cartao_id.present?
    relacao
  end

  def compras
    @compras ||= compras_relacao.group(:categoria_id).sum(:valor_total)
  end

  def compras_qtd
    @compras_qtd ||= compras_relacao.group(:categoria_id).count
  end
end
