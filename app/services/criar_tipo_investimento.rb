class CriarTipoInvestimento < ApplicationService
  def initialize(nome:)
    @nome = nome
  end

  def call
    tipo = TipoInvestimento.new(nome: @nome)

    if tipo.save
      Resultado.sucesso(valor: tipo)
    else
      Resultado.erro(*tipo.errors.full_messages, valor: tipo)
    end
  end
end
