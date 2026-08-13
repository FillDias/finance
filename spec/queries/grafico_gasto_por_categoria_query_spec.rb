require "rails_helper"

RSpec.describe GraficoGastoPorCategoriaQuery do
  it "monta barras horizontais com a maior categoria no topo do eixo" do
    mercado = Categoria.create!(nome: "Mercado")
    lazer = Categoria.create!(nome: "Lazer")
    Despesa.create!(valor: 600, data: Date.current, categoria: mercado, tipo: :variavel, forma_pagamento: :dinheiro)
    Despesa.create!(valor: 100, data: Date.current, categoria: lazer, tipo: :variavel, forma_pagamento: :pix)

    opcao = GraficoGastoPorCategoriaQuery.call(mes: Date.current)

    expect(opcao[:yAxis][:data]).to eq([ "Lazer", "Mercado" ])
    expect(opcao[:series].first[:data].last[:value]).to eq(600.to_d)
    expect(opcao[:series].first[:data].last[:chave]).to eq(mercado.id)
  end

  it "não quebra quando não há gasto no mês" do
    opcao = GraficoGastoPorCategoriaQuery.call(mes: Date.current)

    expect(opcao[:series].first[:data]).to eq([])
  end
end
