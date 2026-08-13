require "rails_helper"

RSpec.describe GraficoEntradasVsSaidasQuery do
  it "monta série real de entradas e saídas mais 3 meses de projeção tracejada" do
    Renda.create!(valor: 1000, data: Date.current, fonte: "Salário")
    categoria = Categoria.create!(nome: "Mercado")
    Despesa.create!(valor: 400, data: Date.current, categoria: categoria, tipo: :variavel, forma_pagamento: :dinheiro)

    opcao = GraficoEntradasVsSaidasQuery.call

    expect(opcao[:xAxis][:data].size).to eq(9)

    entradas = opcao[:series].find { |serie| serie[:name] == "Entradas" }
    projecao_entradas = opcao[:series].find { |serie| serie[:name] == "Entradas (projeção)" }
    expect(entradas[:data].last).to be_nil
    expect(entradas[:data][5]).to eq(1000.to_d)
    expect(projecao_entradas[:lineStyle][:type]).to eq("dashed")
    expect(projecao_entradas[:data].last).not_to be_nil
  end

  it "não quebra quando não há lançamento nenhum" do
    opcao = GraficoEntradasVsSaidasQuery.call

    entradas = opcao[:series].find { |serie| serie[:name] == "Entradas" }
    expect(entradas).not_to be_nil
  end

  it "adiciona uma markLine de comparação anual quando há dado do mesmo mês no ano anterior" do
    Renda.create!(valor: 500, data: Date.current - 1.year, fonte: "Salário")

    opcao = GraficoEntradasVsSaidasQuery.call

    entradas = opcao[:series].find { |serie| serie[:name] == "Entradas" }
    expect(entradas[:markLine][:data].first[:yAxis]).to eq(500.to_d)
  end
end
