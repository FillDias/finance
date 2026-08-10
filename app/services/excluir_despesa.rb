class ExcluirDespesa < ApplicationService
  def initialize(despesa:)
    @despesa = despesa
  end

  def call
    @despesa.destroy
    Resultado.sucesso(valor: @despesa)
  end
end
