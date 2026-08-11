require "rails_helper"

RSpec.describe Credor, type: :model do
  it "é válido com nome" do
    credor = Credor.new(nome: "Nubank")

    expect(credor).to be_valid
  end

  it "é inválido sem nome" do
    credor = Credor.new(nome: nil)

    expect(credor).not_to be_valid
    expect(credor.errors[:nome]).not_to be_empty
  end

  it "é inválido com nome duplicado" do
    Credor.create!(nome: "Nubank")
    credor = Credor.new(nome: "Nubank")

    expect(credor).not_to be_valid
    expect(credor.errors[:nome]).not_to be_empty
  end

  it "impede exclusão quando há cartões associados" do
    credor = Credor.create!(nome: "Santander")
    Cartao.create!(nome: "Santander Free", credor: credor, limite_total: 1000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.current)

    expect(credor.destroy).to be false
    expect(credor.errors[:base]).not_to be_empty
  end
end
