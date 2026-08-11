class MarcarFaturaComoPaga < ApplicationService
  def initialize(cartao_id:, mes_referencia:, valor_pago:, data_pagamento:)
    @cartao_id = cartao_id
    @mes_referencia_bruta = mes_referencia
    @valor_pago = valor_pago
    @data_pagamento = data_pagamento
  end

  def call
    mes = normalizar_mes(@mes_referencia_bruta)
    return Resultado.erro("Mês de referência inválido") unless mes

    pagamento = FaturaPagamento.find_or_initialize_by(cartao_id: @cartao_id, mes_referencia: mes)
    pagamento.assign_attributes(valor_pago: @valor_pago, data_pagamento: @data_pagamento)

    if pagamento.save
      Resultado.sucesso(valor: pagamento)
    else
      Resultado.erro(*pagamento.errors.full_messages, valor: pagamento)
    end
  end

  private

  def normalizar_mes(valor)
    data = valor.is_a?(Date) ? valor : Date.parse(valor.to_s)
    data.beginning_of_month
  rescue ArgumentError, TypeError
    nil
  end
end
