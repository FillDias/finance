class QuitarSaldoHerdado < ApplicationService
  def initialize(saldo_herdado:, valor_pago:, data_pagamento:)
    @saldo_herdado = saldo_herdado
    @valor_pago = valor_pago
    @data_pagamento = data_pagamento
  end

  def call
    if @saldo_herdado.update(valor_pago: @valor_pago, data_pagamento: @data_pagamento)
      Resultado.sucesso(valor: @saldo_herdado)
    else
      Resultado.erro(*@saldo_herdado.errors.full_messages, valor: @saldo_herdado)
    end
  end
end
