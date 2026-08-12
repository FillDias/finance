require "rails_helper"

RSpec.describe ExcluirTipoInvestimento do
  it "remove o tipo sem investimentos associados" do
    tipo = TipoInvestimento.create!(nome: "Cripto")

    resultado = ExcluirTipoInvestimento.call(tipo_investimento: tipo)

    expect(resultado).to be_sucesso
    expect(TipoInvestimento.exists?(tipo.id)).to be false
  end

  it "retorna erro e mantém o tipo quando há investimentos associados" do
    tipo = TipoInvestimento.create!(nome: "CDB")
    Investimento.create!(tipo_investimento: tipo, instituicao: "Nubank", taxa_rendimento: 1.1, periodicidade_taxa: :mensal, status: :ativo)

    resultado = ExcluirTipoInvestimento.call(tipo_investimento: tipo)

    expect(resultado).to be_erro
    expect(TipoInvestimento.exists?(tipo.id)).to be true
  end
end
