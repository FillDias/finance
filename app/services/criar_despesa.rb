class CriarDespesa < ApplicationService
  FORMA_PAGAMENTO_CARTAO = "cartao"

  def initialize(valor:, data:, categoria_id:, tipo:, forma_pagamento:, dia_vencimento: nil, cartao_id: nil, parcelado: false, numero_parcelas: nil)
    @valor = valor
    @data = data
    @categoria_id = categoria_id
    @tipo = tipo
    @forma_pagamento = forma_pagamento
    @dia_vencimento = dia_vencimento
    @cartao_id = cartao_id
    @parcelado = parcelado
    @numero_parcelas = numero_parcelas
  end

  def call
    return criar_como_compra if forma_pagamento_cartao?

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

  private

  def forma_pagamento_cartao?
    @forma_pagamento.to_s == FORMA_PAGAMENTO_CARTAO
  end

  # Uma Despesa paga no cartão não gera um registro Despesa próprio — vira uma
  # Compra no cartão escolhido, carregando a categoria e a classificação
  # fixa/variável. Evita contar o mesmo gasto duas vezes (ver ticket #9 / ADR).
  def criar_como_compra
    CriarCompraNoCartao.call(
      cartao_id: @cartao_id,
      data_compra: @data,
      valor_total: @valor,
      parcelado: @parcelado,
      numero_parcelas: @numero_parcelas,
      categoria_id: @categoria_id,
      tipo: @tipo
    )
  end
end
