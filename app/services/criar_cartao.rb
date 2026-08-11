class CriarCartao < ApplicationService
  def initialize(nome:, credor_id:, limite_total:, dia_fechamento:, dia_vencimento:, data_corte:)
    @nome = nome
    @credor_id = credor_id
    @limite_total = limite_total
    @dia_fechamento = dia_fechamento
    @dia_vencimento = dia_vencimento
    @data_corte = data_corte
  end

  def call
    cartao = Cartao.new(
      nome: @nome,
      credor_id: @credor_id,
      limite_total: @limite_total,
      dia_fechamento: @dia_fechamento,
      dia_vencimento: @dia_vencimento,
      data_corte: @data_corte
    )

    if cartao.save
      Resultado.sucesso(valor: cartao)
    else
      Resultado.erro(*cartao.errors.full_messages, valor: cartao)
    end
  end
end
