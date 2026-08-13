require "rails_helper"

RSpec.describe GraficoEntradasPorFonteQuery do
  it "monta uma série empilhada por fonte, nos últimos meses" do
    Renda.create!(valor: 1000, data: Date.current, fonte: "Salário")
    Renda.create!(valor: 300, data: Date.current, fonte: "Freela")

    opcao = GraficoEntradasPorFonteQuery.call(meses: 3)

    nomes_das_series = opcao[:series].map { |serie| serie[:name] }
    expect(nomes_das_series).to contain_exactly("Salário", "Freela")
    expect(opcao[:series].find { |s| s[:name] == "Salário" }[:data].last).to eq(1000.to_d)
    expect(opcao[:xAxis][:data].size).to eq(3)
  end
end
