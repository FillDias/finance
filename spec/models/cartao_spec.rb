require "rails_helper"

RSpec.describe Cartao, type: :model do
  let(:credor) { Credor.create!(nome: "Nubank") }

  def cartao_valido(atributos = {})
    Cartao.new(
      { nome: "Nubank Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.current }.merge(atributos)
    )
  end

  it "é válido com todos os atributos" do
    expect(cartao_valido).to be_valid
  end

  it "é inválido sem nome" do
    cartao = cartao_valido(nome: nil)

    expect(cartao).not_to be_valid
    expect(cartao.errors[:nome]).not_to be_empty
  end

  it "é inválido sem credor" do
    cartao = cartao_valido(credor: nil)

    expect(cartao).not_to be_valid
  end

  it "é inválido com limite_total zero ou negativo" do
    cartao = cartao_valido(limite_total: 0)

    expect(cartao).not_to be_valid
    expect(cartao.errors[:limite_total]).not_to be_empty
  end

  it "é inválido com dia_fechamento fora do intervalo 1..31" do
    cartao = cartao_valido(dia_fechamento: 32)

    expect(cartao).not_to be_valid
    expect(cartao.errors[:dia_fechamento]).not_to be_empty
  end

  it "é inválido com dia_vencimento fora do intervalo 1..31" do
    cartao = cartao_valido(dia_vencimento: 0)

    expect(cartao).not_to be_valid
    expect(cartao.errors[:dia_vencimento]).not_to be_empty
  end

  it "é inválido sem data_corte" do
    cartao = cartao_valido(data_corte: nil)

    expect(cartao).not_to be_valid
    expect(cartao.errors[:data_corte]).not_to be_empty
  end
end
