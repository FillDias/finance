require "rails_helper"

RSpec.describe AtualizarCategoria do
  it "atualiza o nome e retorna sucesso" do
    categoria = Categoria.create!(nome: "Lazer")

    resultado = AtualizarCategoria.call(categoria: categoria, nome: "Entretenimento")

    expect(resultado).to be_sucesso
    expect(categoria.reload.nome).to eq("Entretenimento")
  end

  it "retorna erro quando o novo nome já existe em outra categoria" do
    Categoria.create!(nome: "Saúde")
    categoria = Categoria.create!(nome: "Lazer")

    resultado = AtualizarCategoria.call(categoria: categoria, nome: "Saúde")

    expect(resultado).to be_erro
    expect(categoria.reload.nome).to eq("Lazer")
  end
end
