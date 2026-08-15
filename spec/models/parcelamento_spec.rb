require "rails_helper"

RSpec.describe Parcelamento, type: :model do
  let(:categoria) { Categoria.create!(nome: "Mercado") }

  it "é válido com numero_parcelas >= 2" do
    parcelamento = Parcelamento.new(
      valor_total: 300, numero_parcelas: 3, data: Date.new(2026, 7, 1),
      categoria: categoria, tipo: :variavel, forma_pagamento: :boleto
    )

    expect(parcelamento).to be_valid
  end

  it "é inválido com numero_parcelas 1 — Parcelamento só existe pro caso parcelado" do
    parcelamento = Parcelamento.new(
      valor_total: 300, numero_parcelas: 1, data: Date.new(2026, 7, 1),
      categoria: categoria, tipo: :variavel, forma_pagamento: :boleto
    )

    expect(parcelamento).not_to be_valid
    expect(parcelamento.errors[:numero_parcelas]).not_to be_empty
  end

  it "é inválido sem data" do
    parcelamento = Parcelamento.new(
      valor_total: 300, numero_parcelas: 3, data: nil, categoria: categoria, tipo: :variavel, forma_pagamento: :boleto
    )

    expect(parcelamento).not_to be_valid
  end

  it "é inválido com valor total zero ou negativo" do
    parcelamento = Parcelamento.new(
      valor_total: 0, numero_parcelas: 3, data: Date.current, categoria: categoria, tipo: :variavel, forma_pagamento: :boleto
    )

    expect(parcelamento).not_to be_valid
  end

  it "é inválido sem forma de pagamento" do
    parcelamento = Parcelamento.new(valor_total: 300, numero_parcelas: 3, data: Date.current, categoria: categoria, tipo: :variavel)

    expect(parcelamento).not_to be_valid
  end
end
