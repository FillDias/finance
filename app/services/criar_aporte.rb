class CriarAporte < ApplicationService
  def initialize(investimento_id:, valor:, data:)
    @investimento_id = investimento_id
    @valor = valor
    @data = data
  end

  def call
    aporte = Aporte.new(investimento_id: @investimento_id, valor: @valor, data: @data)

    if aporte.save
      Resultado.sucesso(valor: aporte)
    else
      Resultado.erro(*aporte.errors.full_messages, valor: aporte)
    end
  end
end
