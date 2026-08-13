class AtualizarAporte < ApplicationService
  def initialize(aporte:, valor:, data:)
    @aporte = aporte
    @valor = valor
    @data = data
  end

  def call
    if @aporte.update(valor: @valor, data: @data)
      Resultado.sucesso(valor: @aporte)
    else
      Resultado.erro(*@aporte.errors.full_messages, valor: @aporte)
    end
  end
end
