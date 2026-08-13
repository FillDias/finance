class AtualizarTaxaCdi < ApplicationService
  def initialize(valor:)
    @valor = valor
  end

  def call
    taxa = TaxaCdi.atual

    if taxa.update(valor: @valor)
      Resultado.sucesso(valor: taxa)
    else
      Resultado.erro(*taxa.errors.full_messages, valor: taxa)
    end
  end
end
