require "rails_helper"

RSpec.describe GraficoSparklineSaldoQuery do
  it "monta uma opção de linha sem eixos com a série de saldo dos últimos meses" do
    Renda.create!(valor: 1000, data: Date.current, fonte: "Salário")
    categoria = Categoria.create!(nome: "Mercado")
    Despesa.create!(valor: 400, data: Date.current, categoria: categoria, tipo: :variavel, forma_pagamento: :dinheiro)

    opcao = GraficoSparklineSaldoQuery.call(meses: 3)

    expect(opcao[:series].first[:data].last).to eq(600.to_d)
    expect(opcao[:series].first[:data].size).to eq(3)
  end
end
