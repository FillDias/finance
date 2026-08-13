# Soma Despesa + Compra-com-categoria (Despesa paga no cartão, ver ticket
# #9) — mesma regra de "mesma linha, nunca duas" que DespesasFiltradas usa
# pra listar, só que aqui somando em vez de listar. categoria_id/cartao_id
# são os mesmos filtros do topo do Painel (ver PainelController) — cartao_id
# só filtra Compra, já que Despesa não pertence a nenhum Cartão.
class SaidasDoMesQuery < ApplicationQuery
  def initialize(mes: Date.current, categoria_id: nil, cartao_id: nil)
    @mes = mes.to_date.beginning_of_month
    @categoria_id = categoria_id
    @cartao_id = cartao_id
  end

  def call
    despesas + compras_categorizadas
  end

  private

  def despesas
    return 0 if @cartao_id.present?

    relacao = Despesa.where(data: @mes..@mes.end_of_month)
    relacao = relacao.where(categoria_id: @categoria_id) if @categoria_id.present?
    relacao.sum(:valor)
  end

  def compras_categorizadas
    relacao = Compra.where(data_compra: @mes..@mes.end_of_month).where.not(categoria_id: nil)
    relacao = relacao.where(categoria_id: @categoria_id) if @categoria_id.present?
    relacao = relacao.where(cartao_id: @cartao_id) if @cartao_id.present?
    relacao.sum(:valor_total)
  end
end
