# Soma Despesa + parcelas-com-categoria vencendo no mês (Compra, Parcelamento,
# Emprestimo) — mesma regra de "mesma linha, nunca duas" que DespesasFiltradas
# usa pra listar, só que aqui somando em vez de listar. Fundamental: soma
# sempre pela Parcela que vence no mês, nunca pelo valor total do lançamento
# de origem — uma Compra/Parcelamento/Emprestimo parcelado só deve contribuir
# com a fração que vence naquele mês específico (ver ObrigacoesQuery, que já
# fazia isso certo; esta query tinha regredido pra somar Compra.valor_total
# direto, contando o total inteiro no mês da compra).
# categoria_id/cartao_id são os mesmos filtros do topo do Painel (ver
# PainelController) — cartao_id só filtra Compra, já que Despesa/Parcelamento/
# Emprestimo não pertencem a nenhum Cartão.
class SaidasDoMesQuery < ApplicationQuery
  def initialize(mes: Date.current, categoria_id: nil, cartao_id: nil)
    @mes = mes.to_date.beginning_of_month
    @categoria_id = categoria_id
    @cartao_id = cartao_id
  end

  def call
    despesas + compras + parcelamentos + emprestimos
  end

  private

  def periodo
    @mes..@mes.end_of_month
  end

  def despesas
    return 0 if @cartao_id.present?

    relacao = Despesa.where(data: periodo)
    relacao = relacao.where(categoria_id: @categoria_id) if @categoria_id.present?
    relacao.sum(:valor)
  end

  def compras
    relacao = Compra.where.not(categoria_id: nil).joins(:parcelas).where(parcelas: { data_vencimento: periodo })
    relacao = relacao.where(categoria_id: @categoria_id) if @categoria_id.present?
    relacao = relacao.where(cartao_id: @cartao_id) if @cartao_id.present?
    relacao.sum("parcelas.valor")
  end

  def parcelamentos
    return 0 if @cartao_id.present?

    relacao = Parcelamento.joins(:parcelas).where(parcelas: { data_vencimento: periodo })
    relacao = relacao.where(categoria_id: @categoria_id) if @categoria_id.present?
    relacao.sum("parcelas.valor")
  end

  def emprestimos
    return 0 if @cartao_id.present?

    relacao = Emprestimo.joins(:parcelas).where(parcelas: { data_vencimento: periodo })
    relacao = relacao.where(categoria_id: @categoria_id) if @categoria_id.present?
    relacao.sum("parcelas.valor")
  end
end
