# Fatura de cada Cartão no mês informado (via FaturaProjetadaQuery), do
# maior valor pro menor. cartao_id restringe a um único cartão (filtro do
# topo do Painel).
class FaturaPorCartaoQuery < ApplicationQuery
  def initialize(mes: Date.current, cartao_id: nil)
    @mes = mes.to_date.beginning_of_month
    @cartao_id = cartao_id
  end

  def call
    cartoes.map { |cartao| linha(cartao) }
           .select { |item| item[:valor].positive? }
           .sort_by { |item| -item[:valor] }
  end

  private

  def cartoes
    relacao = Cartao.order(:nome)
    relacao = relacao.where(id: @cartao_id) if @cartao_id.present?
    relacao
  end

  def linha(cartao)
    fatura = FaturaProjetadaQuery.call(cartao: cartao, mes: @mes)
    {
      cartao_id: cartao.id, cartao: cartao.nome, valor: fatura.total,
      saldo_herdado: fatura.saldo_herdado_valor, parcelas: fatura.parcelas_valor
    }
  end
end
