require "rails_helper"

RSpec.describe GraficoExemploQuery do
  it "monta a opção do ECharts a partir da renda por fonte do ano" do
    Renda.create!(valor: 1000, data: Date.new(2026, 1, 5), fonte: "Salário")
    Renda.create!(valor: 300, data: Date.new(2026, 3, 20), fonte: "Freela")

    opcao = GraficoExemploQuery.call(ano: 2026)

    expect(opcao[:xAxis][:data]).to contain_exactly("Salário", "Freela")
    expect(opcao[:series].first[:type]).to eq("bar")
    expect(opcao[:series].first[:data]).to contain_exactly(1000.0.to_d, 300.0.to_d)
  end

  it "usa o ano corrente por padrão" do
    Renda.create!(valor: 500, data: Date.current, fonte: "Salário")

    opcao = GraficoExemploQuery.call

    expect(opcao[:xAxis][:data]).to eq([ "Salário" ])
  end
end
