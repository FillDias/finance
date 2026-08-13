require "rails_helper"

RSpec.describe EntradasDoMesQuery do
  it "soma as rendas do mês informado" do
    Renda.create!(valor: 1000, data: Date.new(2026, 3, 5), fonte: "Salário")
    Renda.create!(valor: 300, data: Date.new(2026, 3, 20), fonte: "Freela")
    Renda.create!(valor: 500, data: Date.new(2026, 4, 1), fonte: "Salário")

    expect(EntradasDoMesQuery.call(mes: Date.new(2026, 3, 15))).to eq(1300.to_d)
  end

  it "usa o mês atual por padrão" do
    Renda.create!(valor: 200, data: Date.current, fonte: "Salário")

    expect(EntradasDoMesQuery.call).to eq(200.to_d)
  end

  it "retorna zero quando não há rendas no mês" do
    expect(EntradasDoMesQuery.call(mes: Date.new(2026, 3, 1))).to eq(0)
  end
end
