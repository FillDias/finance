class AtualizarDespesa < ApplicationService
  def initialize(despesa:, valor:, data:, categoria_id:, tipo:, forma_pagamento:, dia_vencimento: nil)
    @despesa = despesa
    @valor = valor
    @data = data
    @categoria_id = categoria_id
    @tipo = tipo
    @forma_pagamento = forma_pagamento
    @dia_vencimento = dia_vencimento
  end

  def call
    if @despesa.update(
      valor: @valor,
      data: @data,
      categoria_id: @categoria_id,
      tipo: @tipo,
      forma_pagamento: @forma_pagamento,
      dia_vencimento: @dia_vencimento
    )
      Resultado.sucesso(valor: @despesa)
    else
      Resultado.erro(*@despesa.errors.full_messages, valor: @despesa)
    end
  end
end
