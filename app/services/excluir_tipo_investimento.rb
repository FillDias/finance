class ExcluirTipoInvestimento < ApplicationService
  def initialize(tipo_investimento:)
    @tipo_investimento = tipo_investimento
  end

  def call
    if @tipo_investimento.destroy
      Resultado.sucesso(valor: @tipo_investimento)
    else
      Resultado.erro(*@tipo_investimento.errors.full_messages, valor: @tipo_investimento)
    end
  end
end
