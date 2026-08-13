require "rails_helper"

RSpec.describe DistribuicaoPorTipoQuery do
  let(:cdb) { TipoInvestimento.create!(nome: "CDB") }
  let(:tesouro) { TipoInvestimento.create!(nome: "Tesouro Direto") }

  it "soma aportes de investimentos ativos, agrupados por tipo" do
    inv_cdb = Investimento.create!(tipo_investimento: cdb, instituicao: "Nubank", taxa_rendimento: 1.1, periodicidade_taxa: :mensal, status: :ativo)
    inv_tesouro = Investimento.create!(tipo_investimento: tesouro, instituicao: "XP", taxa_rendimento: 10, periodicidade_taxa: :anual, status: :ativo)
    Aporte.create!(investimento: inv_cdb, valor: 500, data: Date.current)
    Aporte.create!(investimento: inv_tesouro, valor: 300, data: Date.current)
    Aporte.create!(investimento: inv_tesouro, valor: 200, data: Date.current)

    resultado = DistribuicaoPorTipoQuery.call

    expect(resultado).to eq({ "CDB" => 500.to_d, "Tesouro Direto" => 500.to_d })
  end

  it "não inclui aportes de investimentos resgatados" do
    resgatado = Investimento.create!(
      tipo_investimento: cdb, instituicao: "Nubank", taxa_rendimento: 1.1, periodicidade_taxa: :mensal,
      status: :resgatado, valor_resgatado: 600, data_resgate: Date.current
    )
    Aporte.create!(investimento: resgatado, valor: 500, data: Date.current)

    expect(DistribuicaoPorTipoQuery.call).to eq({})
  end

  it "retorna hash vazio quando não há aportes" do
    expect(DistribuicaoPorTipoQuery.call).to eq({})
  end
end
