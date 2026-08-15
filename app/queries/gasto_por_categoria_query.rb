# Agrupa por categoria a soma de Despesa + parcelas-com-categoria vencendo no
# mês (Compra, Parcelamento, Emprestimo), do maior gasto pro menor. Mesma
# regra de "soma pela Parcela que vence no mês, nunca pelo valor total do
# lançamento de origem" que SaidasDoMesQuery aplica — ver o comentário lá.
# categoria_id/cartao_id são os mesmos filtros do topo do Painel — cartao_id
# restringe a Compra e exclui Despesa/Parcelamento/Emprestimo, mesma regra de
# SaidasDoMesQuery.
class GastoPorCategoriaQuery < ApplicationQuery
  def initialize(mes: Date.current, categoria_id: nil, cartao_id: nil)
    @mes = mes.to_date.beginning_of_month
    @categoria_id = categoria_id
    @cartao_id = cartao_id
  end

  def call
    ids = despesas.keys | compras.keys | parcelamentos.keys | emprestimos.keys
    nomes = Categoria.where(id: ids).pluck(:id, :nome).to_h

    ids.map { |id| linha(id, nomes.fetch(id)) }.sort_by { |item| -item[:valor] }
  end

  private

  def periodo
    @mes..@mes.end_of_month
  end

  def linha(id, nome)
    valor_despesas = despesas.fetch(id, 0)
    valor_compras = compras.fetch(id, 0)
    valor_parcelamentos = parcelamentos.fetch(id, 0)
    valor_emprestimos = emprestimos.fetch(id, 0)

    {
      categoria_id: id, categoria: nome,
      valor: valor_despesas + valor_compras + valor_parcelamentos + valor_emprestimos,
      despesas: valor_despesas, compras: valor_compras, compras_qtd: compras_qtd.fetch(id, 0),
      parcelamentos: valor_parcelamentos, emprestimos: valor_emprestimos
    }
  end

  def despesas
    return {} if @cartao_id.present?

    relacao = Despesa.where(data: periodo)
    relacao = relacao.where(categoria_id: @categoria_id) if @categoria_id.present?
    @despesas ||= relacao.group(:categoria_id).sum(:valor)
  end

  def compras_relacao
    relacao = Compra.where.not(categoria_id: nil).joins(:parcelas).where(parcelas: { data_vencimento: periodo })
    relacao = relacao.where(categoria_id: @categoria_id) if @categoria_id.present?
    relacao = relacao.where(cartao_id: @cartao_id) if @cartao_id.present?
    relacao
  end

  def compras
    @compras ||= compras_relacao.group(:categoria_id).sum("parcelas.valor")
  end

  def compras_qtd
    @compras_qtd ||= compras_relacao.distinct.group(:categoria_id).count(:id)
  end

  def parcelamentos
    return {} if @cartao_id.present?

    relacao = Parcelamento.joins(:parcelas).where(parcelas: { data_vencimento: periodo })
    relacao = relacao.where(categoria_id: @categoria_id) if @categoria_id.present?
    @parcelamentos ||= relacao.group(:categoria_id).sum("parcelas.valor")
  end

  def emprestimos
    return {} if @cartao_id.present?

    relacao = Emprestimo.joins(:parcelas).where(parcelas: { data_vencimento: periodo })
    relacao = relacao.where(categoria_id: @categoria_id) if @categoria_id.present?
    @emprestimos ||= relacao.group(:categoria_id).sum("parcelas.valor")
  end
end
