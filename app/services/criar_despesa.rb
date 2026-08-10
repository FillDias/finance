class CriarDespesa < ApplicationService
  def initialize(valor:, data:, categoria_id:, tipo:, forma_pagamento:, dia_vencimento: nil)
    @valor = valor
    @data = data
    @categoria_id = categoria_id
    @tipo = tipo
    @forma_pagamento = forma_pagamento
    @dia_vencimento = dia_vencimento
  end

  def call
    despesa = Despesa.new(
      valor: @valor,
      data: @data,
      categoria_id: @categoria_id,
      tipo: @tipo,
      forma_pagamento: @forma_pagamento,
      dia_vencimento: @dia_vencimento
    )

    if despesa.save
      Resultado.sucesso(valor: despesa)
    else
      Resultado.erro(*despesa.errors.full_messages, valor: despesa)
    end
  end
end
