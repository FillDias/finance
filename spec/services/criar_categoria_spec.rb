require "rails_helper"

RSpec.describe CriarCategoria do
  it "cria a categoria e retorna sucesso quando o nome é válido" do
    resultado = CriarCategoria.call(nome: "Transporte")

    expect(resultado).to be_sucesso
    expect(resultado.valor).to be_persisted
  end

  it "não cria e retorna erro quando o nome já existe" do
    Categoria.create!(nome: "Transporte")

    resultado = CriarCategoria.call(nome: "Transporte")

    expect(resultado).to be_erro
    expect(Categoria.count).to eq(1)
  end
end
