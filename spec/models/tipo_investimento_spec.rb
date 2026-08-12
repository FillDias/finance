require "rails_helper"

RSpec.describe TipoInvestimento, type: :model do
  it "é válido com nome" do
    tipo = TipoInvestimento.new(nome: "CDB")

    expect(tipo).to be_valid
  end

  it "é inválido sem nome" do
    tipo = TipoInvestimento.new(nome: nil)

    expect(tipo).not_to be_valid
  end

  it "é inválido com nome duplicado" do
    TipoInvestimento.create!(nome: "CDB")
    tipo = TipoInvestimento.new(nome: "CDB")

    expect(tipo).not_to be_valid
  end

  it "impede exclusão quando há investimentos associados" do
    tipo = TipoInvestimento.create!(nome: "CDB")
    Investimento.create!(tipo_investimento: tipo, instituicao: "Nubank", taxa_rendimento: 1.1, periodicidade_taxa: :mensal, status: :ativo)

    expect(tipo.destroy).to be false
  end
end
