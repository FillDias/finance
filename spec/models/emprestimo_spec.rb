require "rails_helper"

RSpec.describe Emprestimo, type: :model do
  let(:credor) { Credor.create!(nome: "Caixa") }

  it "é válido com nome, credor e valor total" do
    emprestimo = Emprestimo.new(nome: "Financiamento do carro", credor: credor, valor_total: 30000)

    expect(emprestimo).to be_valid
  end

  it "é inválido sem nome" do
    emprestimo = Emprestimo.new(nome: nil, credor: credor, valor_total: 30000)

    expect(emprestimo).not_to be_valid
  end

  it "é inválido sem credor" do
    emprestimo = Emprestimo.new(nome: "Financiamento do carro", credor: nil, valor_total: 30000)

    expect(emprestimo).not_to be_valid
  end

  it "é inválido com valor total zero ou negativo" do
    emprestimo = Emprestimo.new(nome: "Financiamento do carro", credor: credor, valor_total: 0)

    expect(emprestimo).not_to be_valid
  end
end
