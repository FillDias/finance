class AtualizarCategoria < ApplicationService
  def initialize(categoria:, nome:)
    @categoria = categoria
    @nome = nome
  end

  def call
    if @categoria.update(nome: @nome)
      Resultado.sucesso(valor: @categoria)
    else
      Resultado.erro(*@categoria.errors.full_messages, valor: @categoria)
    end
  end
end
