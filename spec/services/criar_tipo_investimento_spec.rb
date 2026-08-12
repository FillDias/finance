require "rails_helper"

RSpec.describe CriarTipoInvestimento do
  it "cria o tipo e retorna sucesso quando o nome é válido" do
    resultado = CriarTipoInvestimento.call(nome: "Criptoativos")

    expect(resultado).to be_sucesso
    expect(resultado.valor).to be_persisted
  end

  it "não cria e retorna erro quando o nome já existe" do
    TipoInvestimento.create!(nome: "CDB")

    resultado = CriarTipoInvestimento.call(nome: "CDB")

    expect(resultado).to be_erro
    expect(TipoInvestimento.count).to eq(1)
  end
end
