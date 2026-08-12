require "rails_helper"

RSpec.describe Investimento, type: :model do
  let(:tipo) { TipoInvestimento.create!(nome: "CDB") }

  def investimento_valido(atributos = {})
    Investimento.new(
      { tipo_investimento: tipo, instituicao: "Nubank", taxa_rendimento: 1.1, periodicidade_taxa: :mensal, status: :ativo }.merge(atributos)
    )
  end

  it "é válido com todos os atributos obrigatórios" do
    expect(investimento_valido).to be_valid
  end

  it "é válido com data de vencimento opcional ausente" do
    investimento = investimento_valido(data_vencimento: nil)

    expect(investimento).to be_valid
  end

  it "é inválido sem instituição" do
    investimento = investimento_valido(instituicao: nil)

    expect(investimento).not_to be_valid
  end

  it "é inválido sem tipo" do
    investimento = investimento_valido(tipo_investimento: nil)

    expect(investimento).not_to be_valid
  end

  it "é inválido com taxa de rendimento zero ou negativa" do
    investimento = investimento_valido(taxa_rendimento: 0)

    expect(investimento).not_to be_valid
  end

  it "começa ativo por padrão" do
    investimento = investimento_valido
    investimento.save!

    expect(investimento.ativo?).to be true
  end

  it "é inválido com valor resgatado sem data de resgate" do
    investimento = investimento_valido(valor_resgatado: 1000, data_resgate: nil)

    expect(investimento).not_to be_valid
    expect(investimento.errors[:base]).not_to be_empty
  end

  it "é inválido com data de resgate sem valor resgatado" do
    investimento = investimento_valido(valor_resgatado: nil, data_resgate: Date.current)

    expect(investimento).not_to be_valid
    expect(investimento.errors[:base]).not_to be_empty
  end

  it "é válido com valor resgatado e data de resgate juntos" do
    investimento = investimento_valido(status: :resgatado, valor_resgatado: 1050, data_resgate: Date.current)

    expect(investimento).to be_valid
  end

  it "expõe rótulo legível para a periodicidade da taxa" do
    expect(investimento_valido(periodicidade_taxa: :mensal).periodicidade_taxa_label).to eq("% ao mês")
    expect(investimento_valido(periodicidade_taxa: :anual).periodicidade_taxa_label).to eq("% ao ano")
  end
end
