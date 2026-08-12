class AtualizarTipoInvestimento < ApplicationService
  def initialize(tipo_investimento:, nome:)
    @tipo_investimento = tipo_investimento
    @nome = nome
  end

  def call
    if @tipo_investimento.update(nome: @nome)
      Resultado.sucesso(valor: @tipo_investimento)
    else
      Resultado.erro(*@tipo_investimento.errors.full_messages, valor: @tipo_investimento)
    end
  end
end
