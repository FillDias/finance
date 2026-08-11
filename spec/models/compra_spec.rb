require "rails_helper"

RSpec.describe Compra, type: :model do
  let(:credor) { Credor.create!(nome: "Nubank") }
  let(:cartao) { Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 6, 1)) }

  it "é válida à vista (não parcelada, numero_parcelas 1)" do
    compra = Compra.new(cartao: cartao, data_compra: Date.new(2026, 7, 1), valor_total: 100, parcelado: false, numero_parcelas: 1)

    expect(compra).to be_valid
  end

  it "é válida parcelada com numero_parcelas >= 2" do
    compra = Compra.new(cartao: cartao, data_compra: Date.new(2026, 7, 1), valor_total: 300, parcelado: true, numero_parcelas: 3)

    expect(compra).to be_valid
  end

  it "é inválida à vista com numero_parcelas diferente de 1" do
    compra = Compra.new(cartao: cartao, data_compra: Date.new(2026, 7, 1), valor_total: 100, parcelado: false, numero_parcelas: 2)

    expect(compra).not_to be_valid
    expect(compra.errors[:numero_parcelas]).not_to be_empty
  end

  it "é inválida parcelada com numero_parcelas 1" do
    compra = Compra.new(cartao: cartao, data_compra: Date.new(2026, 7, 1), valor_total: 100, parcelado: true, numero_parcelas: 1)

    expect(compra).not_to be_valid
    expect(compra.errors[:numero_parcelas]).not_to be_empty
  end

  it "é inválida sem data de compra" do
    compra = Compra.new(cartao: cartao, data_compra: nil, valor_total: 100, parcelado: false, numero_parcelas: 1)

    expect(compra).not_to be_valid
  end

  it "é inválida com valor total zero ou negativo" do
    compra = Compra.new(cartao: cartao, data_compra: Date.current, valor_total: 0, parcelado: false, numero_parcelas: 1)

    expect(compra).not_to be_valid
  end
end
