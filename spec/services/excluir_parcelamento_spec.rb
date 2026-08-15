require "rails_helper"

RSpec.describe ExcluirParcelamento do
  it "remove o parcelamento e suas parcelas" do
    categoria = Categoria.create!(nome: "Mercado")
    resultado = CriarParcelamento.call(
      valor_total: 300, numero_parcelas: 3, data: Date.new(2026, 7, 10),
      categoria_id: categoria.id, tipo: "variavel", forma_pagamento: "boleto"
    )
    parcelamento = resultado.valor

    ExcluirParcelamento.call(parcelamento: parcelamento)

    expect(Parcelamento.exists?(parcelamento.id)).to be false
    expect(Parcela.where(origem: parcelamento).count).to eq(0)
  end
end
