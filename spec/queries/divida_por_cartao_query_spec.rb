require "rails_helper"

RSpec.describe DividaPorCartaoQuery do
  let(:credor) { Credor.create!(nome: "Nubank") }
  let(:cartao) { Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 1, 1)) }

  it "soma saldo herdado em aberto e parcelas pendentes do cartão" do
    SaldoHerdado.create!(cartao: cartao, mes_referencia: Date.current.beginning_of_month, valor_total: 800)
    CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.current, valor_total: 300, parcelado: false)

    itens = DividaPorCartaoQuery.call

    expect(itens).to eq([ { cartao_id: cartao.id, cartao: "Ultravioleta", valor: 1100.to_d, saldo_herdado: 800.to_d, parcelas: 300.to_d } ])
  end

  it "não inclui saldo herdado já quitado" do
    saldo = SaldoHerdado.create!(cartao: cartao, mes_referencia: Date.current.beginning_of_month, valor_total: 800)
    QuitarSaldoHerdado.call(saldo_herdado: saldo, valor_pago: 800, data_pagamento: Date.current)

    expect(DividaPorCartaoQuery.call).to be_empty
  end

  it "não inclui cartão sem dívida" do
    cartao

    expect(DividaPorCartaoQuery.call).to be_empty
  end
end
