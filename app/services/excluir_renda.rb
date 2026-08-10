class ExcluirRenda < ApplicationService
  def initialize(renda:)
    @renda = renda
  end

  def call
    @renda.destroy
    Resultado.sucesso(valor: @renda)
  end
end
