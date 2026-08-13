require "rails_helper"

RSpec.describe GraficoSparklineTotalInvestidoQuery do
  it "monta uma opção de linha sem eixos, com marcadores de máximo e mínimo" do
    tipo = TipoInvestimento.create!(nome: "CDB")
    investimento = Investimento.create!(tipo_investimento: tipo, instituicao: "Nubank", taxa_rendimento: 1.1, periodicidade_taxa: :mensal, status: :ativo)
    Aporte.create!(investimento: investimento, valor: 500, data: Date.new(2026, 1, 10))
    Aporte.create!(investimento: investimento, valor: 300, data: Date.new(2026, 2, 10))

    opcao = GraficoSparklineTotalInvestidoQuery.call

    expect(opcao[:xAxis][:show]).to be false
    expect(opcao[:yAxis][:show]).to be false
    expect(opcao[:series].first[:data]).to eq([ 500.to_d, 800.to_d ])
    expect(opcao[:series].first[:markPoint][:data].map { |d| d[:type] }).to contain_exactly("max", "min")
  end

  it "não quebra quando não há aportes" do
    opcao = GraficoSparklineTotalInvestidoQuery.call

    expect(opcao[:series].first[:data]).to eq([])
  end

  it "termina no mesmo valor do KPI Total investido, mesmo com aportes de investimentos resgatados" do
    tipo = TipoInvestimento.create!(nome: "CDB")
    ativo = Investimento.create!(tipo_investimento: tipo, instituicao: "Nubank", taxa_rendimento: 1.1, periodicidade_taxa: :mensal, status: :ativo)
    resgatado = Investimento.create!(
      tipo_investimento: tipo, instituicao: "XP", taxa_rendimento: 1.1, periodicidade_taxa: :mensal,
      status: :resgatado, valor_resgatado: 900, data_resgate: Date.current
    )
    Aporte.create!(investimento: ativo, valor: 500, data: Date.current)
    Aporte.create!(investimento: resgatado, valor: 300, data: Date.current)

    opcao = GraficoSparklineTotalInvestidoQuery.call

    expect(opcao[:series].first[:data].last).to eq(TotalInvestidoQuery.call)
  end
end
