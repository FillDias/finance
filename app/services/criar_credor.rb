class CriarCredor < ApplicationService
  def initialize(nome:)
    @nome = nome
  end

  def call
    credor = Credor.new(nome: @nome)

    if credor.save
      Resultado.sucesso(valor: credor)
    else
      Resultado.erro(*credor.errors.full_messages, valor: credor)
    end
  end
end
