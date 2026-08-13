require "rails_helper"

RSpec.describe GraficoSparklineSaidasQuery do
  it "monta uma opção de linha sem eixos com a série de saídas dos últimos meses" do
    categoria = Categoria.create!(nome: "Mercado")
    Despesa.create!(valor: 200, data: Date.current, categoria: categoria, tipo: :variavel, forma_pagamento: :dinheiro)

    opcao = GraficoSparklineSaidasQuery.call(meses: 3)

    expect(opcao[:series].first[:data].last).to eq(200.to_d)
    expect(opcao[:series].first[:data].size).to eq(3)
  end
end
