class ExcluirCategoria < ApplicationService
  def initialize(categoria:)
    @categoria = categoria
  end

  def call
    if @categoria.destroy
      Resultado.sucesso(valor: @categoria)
    else
      Resultado.erro(*@categoria.errors.full_messages, valor: @categoria)
    end
  end
end
