require "rails_helper"

RSpec.describe SaldoRestanteQuery do
  let(:credor) { Credor.create!(nome: "Nubank") }
  let(:cartao) { Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 6, 1)) }

  it "soma saldo herdado em aberto e parcelas pendentes" do
    SaldoHerdado.create!(cartao: cartao, mes_referencia: Date.new(2026, 3, 1), valor_total: 800)
    CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 7, 3), valor_total: 300, parcelado: false)

    expect(SaldoRestanteQuery.call(cartao: cartao)).to eq(1100.to_d)
  end

  it "não conta saldo herdado já quitado antecipadamente" do
    saldo = SaldoHerdado.create!(cartao: cartao, mes_referencia: Date.new(2026, 3, 1), valor_total: 800)
    QuitarSaldoHerdado.call(saldo_herdado: saldo, valor_pago: 700, data_pagamento: Date.current)

    expect(SaldoRestanteQuery.call(cartao: cartao)).to eq(0)
  end

  it "não conta parcelas já pagas" do
    resultado = CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 7, 3), valor_total: 300, parcelado: false)
    resultado.valor.parcelas.first.update!(status: :paga)

    expect(SaldoRestanteQuery.call(cartao: cartao)).to eq(0)
  end

  it "conta parcelas atrasadas (pendentes com vencimento no passado)" do
    CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 6, 3), valor_total: 300, parcelado: false)

    expect(SaldoRestanteQuery.call(cartao: cartao)).to eq(300.to_d)
  end

  it "não mistura saldo de outros cartões" do
    outro_cartao = Cartao.create!(nome: "Gold", credor: credor, limite_total: 2000, dia_fechamento: 10, dia_vencimento: 17, data_corte: Date.new(2026, 6, 1))
    CriarCompraNoCartao.call(cartao_id: outro_cartao.id, data_compra: Date.new(2026, 7, 3), valor_total: 900, parcelado: false)

    expect(SaldoRestanteQuery.call(cartao: cartao)).to eq(0)
  end

  it "retorna zero para um cartão sem nenhum lançamento" do
    expect(SaldoRestanteQuery.call(cartao: cartao)).to eq(0)
  end
end
