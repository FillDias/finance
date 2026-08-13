require "rails_helper"

RSpec.describe GraficoEvolucaoAportesQuery do
  it "monta a opção do ECharts a partir da evolução dos aportes" do
    tipo = TipoInvestimento.create!(nome: "CDB")
    investimento = Investimento.create!(tipo_investimento: tipo, instituicao: "Nubank", taxa_rendimento: 1.1, periodicidade_taxa: :mensal, status: :ativo)
    Aporte.create!(investimento: investimento, valor: 500, data: Date.new(2026, 1, 10))
    Aporte.create!(investimento: investimento, valor: 300, data: Date.new(2026, 2, 10))

    opcao = GraficoEvolucaoAportesQuery.call

    expect(opcao[:xAxis][:data]).to eq([ "01/2026", "02/2026" ])
    expect(opcao[:series].first[:data]).to eq([ 500.to_d, 800.to_d ])
    expect(opcao[:series].first[:type]).to eq("line")
  end

  it "não quebra quando não há aportes" do
    opcao = GraficoEvolucaoAportesQuery.call

    expect(opcao[:xAxis][:data]).to eq([])
    expect(opcao[:series].first[:data]).to eq([])
  end
end
