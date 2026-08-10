require "rails_helper"

RSpec.describe ExcluirCategoria do
  it "remove a categoria sem despesas associadas" do
    categoria = Categoria.create!(nome: "Lazer")

    resultado = ExcluirCategoria.call(categoria: categoria)

    expect(resultado).to be_sucesso
    expect(Categoria.exists?(categoria.id)).to be false
  end

  it "retorna erro e mantém a categoria quando há despesas associadas" do
    categoria = Categoria.create!(nome: "Moradia")
    Despesa.create!(valor: 100, data: Date.current, categoria: categoria, tipo: :variavel, forma_pagamento: :dinheiro)

    resultado = ExcluirCategoria.call(categoria: categoria)

    expect(resultado).to be_erro
    expect(Categoria.exists?(categoria.id)).to be true
  end
end
