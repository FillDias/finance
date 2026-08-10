require "rails_helper"

RSpec.describe TotalDeRendaPorFonte do
  it "soma a renda agrupada por fonte dentro do ano" do
    Renda.create!(valor: 1000, data: Date.new(2026, 1, 5), fonte: "Salário")
    Renda.create!(valor: 500, data: Date.new(2026, 6, 10), fonte: "Salário")
    Renda.create!(valor: 300, data: Date.new(2026, 3, 20), fonte: "Freela")

    resultado = TotalDeRendaPorFonte.call(ano: 2026)

    expect(resultado).to eq({ "Salário" => 1500.0, "Freela" => 300.0 })
  end

  it "ignora lançamentos de outros anos" do
    Renda.create!(valor: 1000, data: Date.new(2025, 12, 31), fonte: "Salário")
    Renda.create!(valor: 200, data: Date.new(2026, 1, 1), fonte: "Salário")

    resultado = TotalDeRendaPorFonte.call(ano: 2026)

    expect(resultado).to eq({ "Salário" => 200.0 })
  end

  it "retorna hash vazio quando não há lançamentos no ano" do
    expect(TotalDeRendaPorFonte.call(ano: 2026)).to eq({})
  end
end
