require "rails_helper"

RSpec.describe SaldoHerdado, type: :model do
  let(:credor) { Credor.create!(nome: "Nubank") }
  let(:cartao) { Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 6, 1)) }

  it "é válido com cartão, mês de referência e valor total" do
    saldo = SaldoHerdado.new(cartao: cartao, mes_referencia: Date.new(2026, 1, 15), valor_total: 1200)

    expect(saldo).to be_valid
  end

  it "normaliza o mês de referência para o primeiro dia do mês" do
    saldo = SaldoHerdado.create!(cartao: cartao, mes_referencia: Date.new(2026, 1, 27), valor_total: 1200)

    expect(saldo.mes_referencia).to eq(Date.new(2026, 1, 1))
  end

  it "é inválido sem mês de referência" do
    saldo = SaldoHerdado.new(cartao: cartao, mes_referencia: nil, valor_total: 1200)

    expect(saldo).not_to be_valid
    expect(saldo.errors[:mes_referencia]).not_to be_empty
  end

  it "é inválido com valor total zero ou negativo" do
    saldo = SaldoHerdado.new(cartao: cartao, mes_referencia: Date.current, valor_total: 0)

    expect(saldo).not_to be_valid
    expect(saldo.errors[:valor_total]).not_to be_empty
  end

  it "é inválido com dois saldos herdados no mesmo mês para o mesmo cartão" do
    SaldoHerdado.create!(cartao: cartao, mes_referencia: Date.new(2026, 1, 1), valor_total: 1200)
    duplicado = SaldoHerdado.new(cartao: cartao, mes_referencia: Date.new(2026, 1, 20), valor_total: 900)

    expect(duplicado).not_to be_valid
    expect(duplicado.errors[:mes_referencia]).not_to be_empty
  end

  it "permite o mesmo mês em cartões diferentes" do
    outro_cartao = Cartao.create!(nome: "Gold", credor: credor, limite_total: 3000, dia_fechamento: 10, dia_vencimento: 17, data_corte: Date.new(2026, 6, 1))
    SaldoHerdado.create!(cartao: cartao, mes_referencia: Date.new(2026, 1, 1), valor_total: 1200)

    outro = SaldoHerdado.new(cartao: outro_cartao, mes_referencia: Date.new(2026, 1, 1), valor_total: 900)

    expect(outro).to be_valid
  end

  it "é inválido com valor pago sem data de pagamento" do
    saldo = SaldoHerdado.new(cartao: cartao, mes_referencia: Date.current, valor_total: 1200, valor_pago: 1000, data_pagamento: nil)

    expect(saldo).not_to be_valid
    expect(saldo.errors[:base]).not_to be_empty
  end

  it "é inválido com data de pagamento sem valor pago" do
    saldo = SaldoHerdado.new(cartao: cartao, mes_referencia: Date.current, valor_total: 1200, valor_pago: nil, data_pagamento: Date.current)

    expect(saldo).not_to be_valid
    expect(saldo.errors[:base]).not_to be_empty
  end

  it "é válido com valor pago e data de pagamento juntos" do
    saldo = SaldoHerdado.new(cartao: cartao, mes_referencia: Date.current, valor_total: 1200, valor_pago: 1000, data_pagamento: Date.current)

    expect(saldo).to be_valid
  end

  describe "#quitado_antecipadamente?" do
    it "é falso sem valor pago" do
      saldo = SaldoHerdado.new(valor_pago: nil)

      expect(saldo.quitado_antecipadamente?).to be false
    end

    it "é verdadeiro com valor pago" do
      saldo = SaldoHerdado.new(valor_pago: 1000)

      expect(saldo.quitado_antecipadamente?).to be true
    end
  end
end
