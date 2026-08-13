require "rails_helper"

RSpec.describe TotalInvestidoQuery do
  let(:tipo) { TipoInvestimento.create!(nome: "CDB") }

  it "soma os aportes de investimentos ativos" do
    ativo = Investimento.create!(tipo_investimento: tipo, instituicao: "Nubank", taxa_rendimento: 1.1, periodicidade_taxa: :mensal, status: :ativo)
    Aporte.create!(investimento: ativo, valor: 500, data: Date.current)
    Aporte.create!(investimento: ativo, valor: 300, data: Date.current)

    expect(TotalInvestidoQuery.call).to eq(800.to_d)
  end

  it "não conta aportes de investimentos resgatados" do
    resgatado = Investimento.create!(
      tipo_investimento: tipo, instituicao: "Nubank", taxa_rendimento: 1.1, periodicidade_taxa: :mensal,
      status: :resgatado, valor_resgatado: 1000, data_resgate: Date.current
    )
    Aporte.create!(investimento: resgatado, valor: 500, data: Date.current)

    expect(TotalInvestidoQuery.call).to eq(0)
  end

  it "retorna zero quando não há aportes" do
    expect(TotalInvestidoQuery.call).to eq(0)
  end
end
