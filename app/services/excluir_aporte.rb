class ExcluirAporte < ApplicationService
  def initialize(aporte:)
    @aporte = aporte
  end

  def call
    @aporte.destroy
    Resultado.sucesso(valor: @aporte)
  end
end
