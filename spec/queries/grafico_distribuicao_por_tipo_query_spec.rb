require "rails_helper"

RSpec.describe GraficoDistribuicaoPorTipoQuery do
  it "monta a opção do ECharts de rosca a partir da distribuição por tipo" do
    cdb = TipoInvestimento.create!(nome: "CDB")
    tesouro = TipoInvestimento.create!(nome: "Tesouro Direto")
    inv_cdb = Investimento.create!(tipo_investimento: cdb, instituicao: "Nubank", taxa_rendimento: 1.1, periodicidade_taxa: :mensal, status: :ativo)
    inv_tesouro = Investimento.create!(tipo_investimento: tesouro, instituicao: "XP", taxa_rendimento: 10, periodicidade_taxa: :anual, status: :ativo)
    Aporte.create!(investimento: inv_cdb, valor: 500, data: Date.current)
    Aporte.create!(investimento: inv_tesouro, valor: 300, data: Date.current)

    opcao = GraficoDistribuicaoPorTipoQuery.call

    expect(opcao[:series].first[:type]).to eq("pie")
    dados = opcao[:series].first[:data]
    expect(dados).to include({ name: "CDB", value: 500.to_d })
    expect(dados).to include({ name: "Tesouro Direto", value: 300.to_d })
  end

  it "retorna série vazia quando não há aportes" do
    opcao = GraficoDistribuicaoPorTipoQuery.call

    expect(opcao[:series].first[:data]).to eq([])
  end
end
