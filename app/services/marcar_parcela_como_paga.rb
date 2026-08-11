class MarcarParcelaComoPaga < ApplicationService
  def initialize(parcela:, data_pagamento: Date.current)
    @parcela = parcela
    @data_pagamento = data_pagamento
  end

  def call
    if @parcela.update(status: :paga, data_pagamento: @data_pagamento)
      Resultado.sucesso(valor: @parcela)
    else
      Resultado.erro(*@parcela.errors.full_messages, valor: @parcela)
    end
  end
end
