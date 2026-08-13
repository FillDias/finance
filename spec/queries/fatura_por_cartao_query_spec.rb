require "rails_helper"

RSpec.describe FaturaPorCartaoQuery do
  let(:credor) { Credor.create!(nome: "Nubank") }

  it "lista a fatura de cada cartão no mês, do maior pro menor" do
    grande = Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 1, 1))
    pequeno = Cartao.create!(nome: "Gold", credor: credor, limite_total: 3000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 1, 1))
    SaldoHerdado.create!(cartao: grande, mes_referencia: Date.current.beginning_of_month, valor_total: 900)
    SaldoHerdado.create!(cartao: pequeno, mes_referencia: Date.current.beginning_of_month, valor_total: 200)

    itens = FaturaPorCartaoQuery.call(mes: Date.current)

    expect(itens).to eq([
      { cartao_id: grande.id, cartao: "Ultravioleta", valor: 900.to_d, saldo_herdado: 900.to_d, parcelas: 0.to_d },
      { cartao_id: pequeno.id, cartao: "Gold", valor: 200.to_d, saldo_herdado: 200.to_d, parcelas: 0.to_d }
    ])
  end

  it "não inclui cartão sem fatura no mês" do
    Cartao.create!(nome: "Sem fatura", credor: credor, limite_total: 1000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 1, 1))

    expect(FaturaPorCartaoQuery.call(mes: Date.current)).to be_empty
  end

  it "restringe a um único cartão quando cartao_id é informado" do
    grande = Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 1, 1))
    pequeno = Cartao.create!(nome: "Gold", credor: credor, limite_total: 3000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 1, 1))
    SaldoHerdado.create!(cartao: grande, mes_referencia: Date.current.beginning_of_month, valor_total: 900)
    SaldoHerdado.create!(cartao: pequeno, mes_referencia: Date.current.beginning_of_month, valor_total: 200)

    itens = FaturaPorCartaoQuery.call(mes: Date.current, cartao_id: grande.id)

    expect(itens.map { |item| item[:cartao] }).to eq([ "Ultravioleta" ])
  end
end
