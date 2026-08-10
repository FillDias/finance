require "rails_helper"

RSpec.describe Categoria, type: :model do
  it "é válida com nome" do
    categoria = Categoria.new(nome: "Alimentação")

    expect(categoria).to be_valid
  end

  it "é inválida sem nome" do
    categoria = Categoria.new(nome: nil)

    expect(categoria).not_to be_valid
    expect(categoria.errors[:nome]).not_to be_empty
  end

  it "é inválida com nome duplicado" do
    Categoria.create!(nome: "Transporte")
    categoria = Categoria.new(nome: "Transporte")

    expect(categoria).not_to be_valid
    expect(categoria.errors[:nome]).not_to be_empty
  end

  it "impede exclusão quando há despesas associadas" do
    categoria = Categoria.create!(nome: "Moradia")
    Despesa.create!(valor: 100, data: Date.current, categoria: categoria, tipo: :variavel, forma_pagamento: :dinheiro)

    expect(categoria.destroy).to be false
    expect(categoria.errors[:base]).not_to be_empty
  end
end
