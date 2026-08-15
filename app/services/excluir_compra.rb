class ExcluirCompra < ApplicationService
  def initialize(compra:)
    @compra = compra
  end

  def call
    @compra.destroy
    Resultado.sucesso(valor: @compra)
  end
end
