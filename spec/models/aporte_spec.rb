require "rails_helper"

RSpec.describe Aporte, type: :model do
  let(:tipo) { TipoInvestimento.create!(nome: "CDB") }
  let(:investimento) { Investimento.create!(tipo_investimento: tipo, instituicao: "Nubank", taxa_rendimento: 1.1, periodicidade_taxa: :mensal, status: :ativo) }

  it "é válido com investimento, valor e data" do
    aporte = Aporte.new(investimento: investimento, valor: 500, data: Date.current)

    expect(aporte).to be_valid
  end

  it "é inválido sem investimento" do
    aporte = Aporte.new(investimento: nil, valor: 500, data: Date.current)

    expect(aporte).not_to be_valid
  end

  it "é inválido sem valor" do
    aporte = Aporte.new(investimento: investimento, valor: nil, data: Date.current)

    expect(aporte).not_to be_valid
  end

  it "é inválido com valor zero ou negativo" do
    aporte = Aporte.new(investimento: investimento, valor: 0, data: Date.current)

    expect(aporte).not_to be_valid
  end

  it "é inválido sem data" do
    aporte = Aporte.new(investimento: investimento, valor: 500, data: nil)

    expect(aporte).not_to be_valid
  end
end
