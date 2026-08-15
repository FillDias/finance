class ExcluirParcelamento < ApplicationService
  def initialize(parcelamento:)
    @parcelamento = parcelamento
  end

  def call
    @parcelamento.destroy
    Resultado.sucesso(valor: @parcelamento)
  end
end
