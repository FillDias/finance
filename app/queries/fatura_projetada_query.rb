class FaturaProjetadaQuery < ApplicationQuery
  def initialize(cartao:, mes:)
    @cartao = cartao
    @mes = mes.beginning_of_month
  end

  def call
    saldo_herdado = @cartao.saldos_herdados.find_by(mes_referencia: @mes)
    pagamento = @cartao.fatura_pagamentos.find_by(mes_referencia: @mes)

    FaturaProjetada.new(
      mes: @mes,
      saldo_herdado_valor: saldo_herdado&.valor_total || 0,
      parcelas_valor: parcelas_do_mes.sum(:valor),
      paga: pagamento.present?,
      valor_pago: pagamento&.valor_pago,
      data_pagamento: pagamento&.data_pagamento
    )
  end

  private

  def parcelas_do_mes
    @cartao.parcelas.where(data_vencimento: @mes..@mes.end_of_month)
  end
end
