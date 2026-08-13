require "rails_helper"

RSpec.describe GraficoSparklineEntradasQuery do
  it "monta uma opção de linha sem eixos com a série de entradas dos últimos meses" do
    Renda.create!(valor: 500, data: Date.current, fonte: "Salário")

    opcao = GraficoSparklineEntradasQuery.call(meses: 3)

    expect(opcao[:xAxis][:show]).to be false
    expect(opcao[:series].first[:data].last).to eq(500.to_d)
    expect(opcao[:series].first[:data].size).to eq(3)
  end
end
