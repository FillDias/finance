require "rails_helper"

RSpec.describe CriarCredor do
  it "cria o credor e retorna sucesso quando o nome é válido" do
    resultado = CriarCredor.call(nome: "Nubank")

    expect(resultado).to be_sucesso
    expect(resultado.valor).to be_persisted
  end

  it "não cria e retorna erro quando o nome já existe" do
    Credor.create!(nome: "Nubank")

    resultado = CriarCredor.call(nome: "Nubank")

    expect(resultado).to be_erro
    expect(Credor.count).to eq(1)
  end
end
