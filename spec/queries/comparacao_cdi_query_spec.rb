require "rails_helper"

RSpec.describe ComparacaoCdiQuery do
  let(:tipo_cdi) { TipoInvestimento.create!(nome: "CDI") }
  let(:tipo_cdb) { TipoInvestimento.create!(nome: "CDB") }

  before { TaxaCdi.atual.update!(valor: 12) }

  it "compara a taxa anualizada de investimentos atrelados a CDI com a taxa CDI global" do
    investimento = Investimento.create!(tipo_investimento: tipo_cdi, instituicao: "Nubank", taxa_rendimento: 1.1, periodicidade_taxa: :mensal, status: :ativo)

    resultado = ComparacaoCdiQuery.call

    comparacao = resultado.first
    expect(comparacao.investimento).to eq(investimento)
    expect(comparacao.taxa_anualizada).to eq(13.2.to_d)
    expect(comparacao.taxa_cdi).to eq(12.to_d)
    expect(comparacao).to be_acima_do_cdi
  end

  it "não anualiza quando a taxa já é ao ano" do
    Investimento.create!(tipo_investimento: tipo_cdi, instituicao: "XP", taxa_rendimento: 10, periodicidade_taxa: :anual, status: :ativo)

    comparacao = ComparacaoCdiQuery.call.first

    expect(comparacao.taxa_anualizada).to eq(10.to_d)
    expect(comparacao).not_to be_acima_do_cdi
  end

  it "não inclui investimentos de outros tipos" do
    Investimento.create!(tipo_investimento: tipo_cdb, instituicao: "Nubank", taxa_rendimento: 1.1, periodicidade_taxa: :mensal, status: :ativo)

    expect(ComparacaoCdiQuery.call).to eq([])
  end

  it "retorna lista vazia quando não há investimentos atrelados a CDI" do
    expect(ComparacaoCdiQuery.call).to eq([])
  end
end
