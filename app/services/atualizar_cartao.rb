class AtualizarCartao < ApplicationService
  def initialize(cartao:, nome:, credor_id:, limite_total:, dia_fechamento:, dia_vencimento:, data_corte:)
    @cartao = cartao
    @nome = nome
    @credor_id = credor_id
    @limite_total = limite_total
    @dia_fechamento = dia_fechamento
    @dia_vencimento = dia_vencimento
    @data_corte = data_corte
  end

  def call
    if @cartao.update(
      nome: @nome,
      credor_id: @credor_id,
      limite_total: @limite_total,
      dia_fechamento: @dia_fechamento,
      dia_vencimento: @dia_vencimento,
      data_corte: @data_corte
    )
      Resultado.sucesso(valor: @cartao)
    else
      Resultado.erro(*@cartao.errors.full_messages, valor: @cartao)
    end
  end
end
