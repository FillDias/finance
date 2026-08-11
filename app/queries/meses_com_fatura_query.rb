class MesesComFaturaQuery < ApplicationQuery
  def initialize(cartao:)
    @cartao = cartao
  end

  def call
    meses_do_saldo_herdado = @cartao.saldos_herdados.pluck(:mes_referencia)
    meses_das_parcelas = @cartao.parcelas.pluck(:data_vencimento).map(&:beginning_of_month)

    (meses_do_saldo_herdado + meses_das_parcelas).uniq.sort
  end
end
