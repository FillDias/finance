require "rails_helper"

RSpec.describe SaldoDoMesQuery do
  let(:categoria) { Categoria.create!(nome: "Mercado") }

  it "é entradas menos saídas do mês" do
    Renda.create!(valor: 1000, data: Date.new(2026, 3, 5), fonte: "Salário")
    Despesa.create!(valor: 300, data: Date.new(2026, 3, 10), categoria: categoria, tipo: :variavel, forma_pagamento: :dinheiro)

    expect(SaldoDoMesQuery.call(mes: Date.new(2026, 3, 1))).to eq(700.to_d)
  end

  it "pode ser negativo quando saídas superam entradas" do
    Renda.create!(valor: 200, data: Date.new(2026, 3, 5), fonte: "Salário")
    Despesa.create!(valor: 500, data: Date.new(2026, 3, 10), categoria: categoria, tipo: :variavel, forma_pagamento: :dinheiro)

    expect(SaldoDoMesQuery.call(mes: Date.new(2026, 3, 1))).to eq(-300.to_d)
  end

  it "não é afetado por Aporte (bloco independente do fluxo de caixa)" do
    Renda.create!(valor: 1000, data: Date.new(2026, 3, 5), fonte: "Salário")
    tipo = TipoInvestimento.create!(nome: "CDB")
    investimento = Investimento.create!(tipo_investimento: tipo, instituicao: "Nubank", taxa_rendimento: 1.1, periodicidade_taxa: :mensal, status: :ativo)
    Aporte.create!(investimento: investimento, valor: 500, data: Date.new(2026, 3, 10))

    expect(SaldoDoMesQuery.call(mes: Date.new(2026, 3, 1))).to eq(1000.to_d)
  end
end
