require "rails_helper"

RSpec.describe GraficoSaldoAcumuladoQuery do
  it "monta um waterfall com base invisível e barra colorida pelo sinal do saldo" do
    Renda.create!(valor: 1000, data: Date.current, fonte: "Salário")
    categoria = Categoria.create!(nome: "Mercado")
    Despesa.create!(valor: 1500, data: Date.current - 1.month, categoria: categoria, tipo: :variavel, forma_pagamento: :dinheiro)

    opcao = GraficoSaldoAcumuladoQuery.call(meses: 3)

    base = opcao[:series].find { |serie| serie[:name] == "Base" }
    delta = opcao[:series].find { |serie| serie[:name] == "Saldo do mês" }
    expect(base[:data].size).to eq(3)
    expect(delta[:data].last[:itemStyle][:color]).to eq(PaletaGrafico::POSITIVO)
    expect(delta[:data][1][:itemStyle][:color]).to eq(PaletaGrafico::NEGATIVO)
    expect(delta[:markPoint][:data].size).to eq(2)
  end
end
