class CriarCategoria < ApplicationService
  def initialize(nome:)
    @nome = nome
  end

  def call
    categoria = Categoria.new(nome: @nome)

    if categoria.save
      Resultado.sucesso(valor: categoria)
    else
      Resultado.erro(*categoria.errors.full_messages, valor: categoria)
    end
  end
end
