class ResgatarInvestimento < ApplicationService
  def initialize(investimento:, valor_resgatado:, data_resgate:)
    @investimento = investimento
    @valor_resgatado = valor_resgatado
    @data_resgate = data_resgate
  end

  def call
    if @investimento.update(status: :resgatado, valor_resgatado: @valor_resgatado, data_resgate: @data_resgate)
      Resultado.sucesso(valor: @investimento)
    else
      Resultado.erro(*@investimento.errors.full_messages, valor: @investimento)
    end
  end
end
