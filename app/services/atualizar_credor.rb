class AtualizarCredor < ApplicationService
  def initialize(credor:, nome:)
    @credor = credor
    @nome = nome
  end

  def call
    if @credor.update(nome: @nome)
      Resultado.sucesso(valor: @credor)
    else
      Resultado.erro(*@credor.errors.full_messages, valor: @credor)
    end
  end
end
