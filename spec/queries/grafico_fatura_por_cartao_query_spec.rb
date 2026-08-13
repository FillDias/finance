require "rails_helper"

RSpec.describe GraficoFaturaPorCartaoQuery do
  it "monta barras horizontais com o cartão de maior fatura no topo" do
    credor = Credor.create!(nome: "Nubank")
    grande = Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 1, 1))
    pequeno = Cartao.create!(nome: "Gold", credor: credor, limite_total: 3000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 1, 1))
    SaldoHerdado.create!(cartao: grande, mes_referencia: Date.current.beginning_of_month, valor_total: 900)
    SaldoHerdado.create!(cartao: pequeno, mes_referencia: Date.current.beginning_of_month, valor_total: 200)

    opcao = GraficoFaturaPorCartaoQuery.call(mes: Date.current)

    expect(opcao[:yAxis][:data]).to eq([ "Gold", "Ultravioleta" ])
  end

  it "inclui a comparação com o mês anterior no tooltip, quando há dado" do
    credor = Credor.create!(nome: "Nubank")
    cartao = Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 1, 1))
    SaldoHerdado.create!(cartao: cartao, mes_referencia: Date.current.beginning_of_month, valor_total: 900)
    SaldoHerdado.create!(cartao: cartao, mes_referencia: Date.current.beginning_of_month - 1.month, valor_total: 300)

    opcao = GraficoFaturaPorCartaoQuery.call(mes: Date.current)
    tooltip = opcao[:series].first[:data].last[:tooltip][:formatter]

    expect(tooltip).to include("Mês anterior: R$ 300,00")
  end
end
