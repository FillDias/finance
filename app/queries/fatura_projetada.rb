FaturaProjetada = Struct.new(
  :mes, :saldo_herdado_valor, :parcelas_valor, :paga, :valor_pago, :data_pagamento,
  keyword_init: true
) do
  def total
    saldo_herdado_valor + parcelas_valor
  end

  def paga?
    paga
  end
end
