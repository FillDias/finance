class AtualizarRenda < ApplicationService
  def initialize(renda:, valor:, data:, fonte:)
    @renda = renda
    @valor = valor
    @data = data
    @fonte = fonte
  end

  def call
    if @renda.update(valor: @valor, data: @data, fonte: @fonte)
      Resultado.sucesso(valor: @renda)
    else
      Resultado.erro(*@renda.errors.full_messages, valor: @renda)
    end
  end
end
