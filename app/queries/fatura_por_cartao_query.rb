# Fatura de cada Cartão no mês informado (via FaturaProjetadaQuery), do
# maior valor pro menor.
class FaturaPorCartaoQuery < ApplicationQuery
  def initialize(mes: Date.current)
    @mes = mes.to_date.beginning_of_month
  end

  def call
    Cartao.order(:nome)
          .map { |cartao| linha(cartao) }
          .select { |item| item[:valor].positive? }
          .sort_by { |item| -item[:valor] }
  end

  private

  def linha(cartao)
    fatura = FaturaProjetadaQuery.call(cartao: cartao, mes: @mes)
    { cartao: cartao.nome, valor: fatura.total, saldo_herdado: fatura.saldo_herdado_valor, parcelas: fatura.parcelas_valor }
  end
end
