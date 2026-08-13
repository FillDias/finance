# Saldo restante (ver CONTEXT.md) de cada Cartão — o valor de cada linha é
# exatamente o que SaldoRestanteQuery já calcula por Cartão, então
# delegamos pra lá em vez de resomar aqui (ADR 0004: uma query não deve
# duplicar a conta que outra já é a fonte da verdade).
class SaldoRestantePorCartaoQuery < ApplicationQuery
  def initialize(cartao_id: nil)
    @cartao_id = cartao_id
  end

  def call
    cartoes.filter_map do |cartao|
      valor = SaldoRestanteQuery.call(cartao: cartao)
      next unless valor.positive?

      { cartao_id: cartao.id, cartao: cartao.nome, valor: valor, saldo_herdado: saldo_herdado(cartao), parcelas: parcelas(cartao) }
    end
  end

  private

  def cartoes
    relacao = Cartao.order(:nome)
    relacao = relacao.where(id: @cartao_id) if @cartao_id.present?
    relacao
  end

  def saldo_herdado(cartao)
    cartao.saldos_herdados.where(valor_pago: nil).sum(:valor_total)
  end

  def parcelas(cartao)
    cartao.parcelas.pendente.sum(:valor)
  end
end
