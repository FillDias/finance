require "rails_helper"

RSpec.describe GraficoSparklineSaidasQuery do
  it "monta uma opção de linha sem eixos com a série de saídas dos últimos meses" do
    categoria = Categoria.create!(nome: "Mercado")
    Despesa.create!(valor: 200, data: Date.current, categoria: categoria, tipo: :variavel, forma_pagamento: :dinheiro)

    opcao = GraficoSparklineSaidasQuery.call(meses: 3)

    expect(opcao[:series].first[:data].last).to eq(200.to_d)
    expect(opcao[:series].first[:data].size).to eq(3)
  end

  it "filtra a série por categoria quando categoria_id é informado" do
    mercado = Categoria.create!(nome: "Mercado")
    lazer = Categoria.create!(nome: "Lazer")
    Despesa.create!(valor: 200, data: Date.current, categoria: mercado, tipo: :variavel, forma_pagamento: :dinheiro)
    Despesa.create!(valor: 90, data: Date.current, categoria: lazer, tipo: :variavel, forma_pagamento: :pix)

    opcao = GraficoSparklineSaidasQuery.call(meses: 3, categoria_id: mercado.id)

    expect(opcao[:series].first[:data].last).to eq(200.to_d)
  end
end
