require "rails_helper"

RSpec.describe FaturaProjetadaQuery do
  let(:credor) { Credor.create!(nome: "Nubank") }
  let(:cartao) { Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 6, 1)) }

  it "soma só o saldo herdado quando o mês não tem parcelas" do
    SaldoHerdado.create!(cartao: cartao, mes_referencia: Date.new(2026, 3, 1), valor_total: 800)

    fatura = FaturaProjetadaQuery.call(cartao: cartao, mes: Date.new(2026, 3, 15))

    expect(fatura.saldo_herdado_valor).to eq(800.to_d)
    expect(fatura.parcelas_valor).to eq(0)
    expect(fatura.total).to eq(800.to_d)
  end

  it "soma só as parcelas quando o mês não tem saldo herdado" do
    CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 7, 3), valor_total: 300, parcelado: false)

    fatura = FaturaProjetadaQuery.call(cartao: cartao, mes: Date.new(2026, 7, 1))

    expect(fatura.saldo_herdado_valor).to eq(0)
    expect(fatura.parcelas_valor).to eq(300.to_d)
    expect(fatura.total).to eq(300.to_d)
  end

  it "soma saldo herdado e parcelas quando o mês tem os dois" do
    SaldoHerdado.create!(cartao: cartao, mes_referencia: Date.new(2026, 7, 1), valor_total: 500)
    CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 7, 3), valor_total: 300, parcelado: false)

    fatura = FaturaProjetadaQuery.call(cartao: cartao, mes: Date.new(2026, 7, 20))

    expect(fatura.saldo_herdado_valor).to eq(500.to_d)
    expect(fatura.parcelas_valor).to eq(300.to_d)
    expect(fatura.total).to eq(800.to_d)
  end

  it "não inclui parcelas de outros meses" do
    CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 7, 3), valor_total: 300, parcelado: false)
    CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 8, 3), valor_total: 100, parcelado: false)

    fatura = FaturaProjetadaQuery.call(cartao: cartao, mes: Date.new(2026, 7, 1))

    expect(fatura.parcelas_valor).to eq(300.to_d)
  end

  it "não inclui parcelas de outros cartões" do
    outro_cartao = Cartao.create!(nome: "Gold", credor: credor, limite_total: 2000, dia_fechamento: 10, dia_vencimento: 17, data_corte: Date.new(2026, 6, 1))
    CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 7, 3), valor_total: 300, parcelado: false)
    CriarCompraNoCartao.call(cartao_id: outro_cartao.id, data_compra: Date.new(2026, 7, 3), valor_total: 900, parcelado: false)

    fatura = FaturaProjetadaQuery.call(cartao: cartao, mes: Date.new(2026, 7, 1))

    expect(fatura.parcelas_valor).to eq(300.to_d)
  end

  it "indica se a fatura já foi marcada como paga" do
    CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 7, 3), valor_total: 300, parcelado: false)
    FaturaPagamento.create!(cartao: cartao, mes_referencia: Date.new(2026, 7, 1), valor_pago: 300, data_pagamento: Date.new(2026, 7, 10))

    fatura = FaturaProjetadaQuery.call(cartao: cartao, mes: Date.new(2026, 7, 1))

    expect(fatura).to be_paga
    expect(fatura.valor_pago).to eq(300.to_d)
  end

  it "indica que a fatura ainda não foi paga quando não há registro de pagamento" do
    fatura = FaturaProjetadaQuery.call(cartao: cartao, mes: Date.new(2026, 7, 1))

    expect(fatura).not_to be_paga
  end
end
