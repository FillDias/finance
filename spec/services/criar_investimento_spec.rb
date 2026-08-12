require "rails_helper"

RSpec.describe CriarInvestimento do
  let(:tipo) { TipoInvestimento.create!(nome: "CDB") }

  it "cria o investimento como ativo quando os dados são válidos" do
    resultado = CriarInvestimento.call(
      tipo_investimento_id: tipo.id, instituicao: "Nubank", taxa_rendimento: 1.1, periodicidade_taxa: "mensal"
    )

    expect(resultado).to be_sucesso
    expect(resultado.valor).to be_persisted
    expect(resultado.valor.ativo?).to be true
  end

  it "aceita data de vencimento opcional" do
    resultado = CriarInvestimento.call(
      tipo_investimento_id: tipo.id, instituicao: "Nubank", taxa_rendimento: 1.1, periodicidade_taxa: "mensal",
      data_vencimento: Date.new(2027, 6, 1)
    )

    expect(resultado.valor.data_vencimento).to eq(Date.new(2027, 6, 1))
  end

  it "não cria e retorna erro quando os dados são inválidos" do
    resultado = CriarInvestimento.call(
      tipo_investimento_id: tipo.id, instituicao: "Nubank", taxa_rendimento: -1, periodicidade_taxa: "mensal"
    )

    expect(resultado).to be_erro
    expect(Investimento.count).to eq(0)
  end
end
