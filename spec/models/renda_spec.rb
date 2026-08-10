require "rails_helper"

RSpec.describe Renda, type: :model do
  it "é válida com valor, data e fonte" do
    renda = Renda.new(valor: 100.50, data: Date.new(2026, 1, 15), fonte: "Salário")

    expect(renda).to be_valid
  end

  it "é inválida sem valor" do
    renda = Renda.new(valor: nil, data: Date.current, fonte: "Salário")

    expect(renda).not_to be_valid
    expect(renda.errors[:valor]).not_to be_empty
  end

  it "é inválida com valor zero ou negativo" do
    renda = Renda.new(valor: 0, data: Date.current, fonte: "Salário")

    expect(renda).not_to be_valid
    expect(renda.errors[:valor]).not_to be_empty
  end

  it "é inválida sem data" do
    renda = Renda.new(valor: 100, data: nil, fonte: "Salário")

    expect(renda).not_to be_valid
    expect(renda.errors[:data]).not_to be_empty
  end

  it "é inválida sem fonte" do
    renda = Renda.new(valor: 100, data: Date.current, fonte: "")

    expect(renda).not_to be_valid
    expect(renda.errors[:fonte]).not_to be_empty
  end
end
