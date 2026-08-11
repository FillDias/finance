class SaldoRestanteQuery < ApplicationQuery
  def initialize(cartao:)
    @cartao = cartao
  end

  def call
    saldo_herdado_em_aberto + parcelas_pendentes
  end

  private

  def saldo_herdado_em_aberto
    @cartao.saldos_herdados.where(valor_pago: nil).sum(:valor_total)
  end

  def parcelas_pendentes
    @cartao.parcelas.pendente.sum(:valor)
  end
end
