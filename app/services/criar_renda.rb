class CriarRenda < ApplicationService
  def initialize(valor:, data:, fonte:)
    @valor = valor
    @data = data
    @fonte = fonte
  end

  def call
    renda = Renda.new(valor: @valor, data: @data, fonte: @fonte)

    if renda.save
      Resultado.sucesso(valor: renda)
    else
      Resultado.erro(*renda.errors.full_messages, valor: renda)
    end
  end
end
