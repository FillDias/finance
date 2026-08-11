require "rails_helper"

RSpec.describe FaturaPagamento, type: :model do
  let(:credor) { Credor.create!(nome: "Nubank") }
  let(:cartao) { Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 6, 1)) }

  it "é válido com cartão, mês, valor pago e data de pagamento" do
    pagamento = FaturaPagamento.new(cartao: cartao, mes_referencia: Date.new(2026, 7, 12), valor_pago: 500, data_pagamento: Date.new(2026, 7, 11))

    expect(pagamento).to be_valid
  end

  it "normaliza o mês de referência para o primeiro dia do mês" do
    pagamento = FaturaPagamento.create!(cartao: cartao, mes_referencia: Date.new(2026, 7, 20), valor_pago: 500, data_pagamento: Date.current)

    expect(pagamento.mes_referencia).to eq(Date.new(2026, 7, 1))
  end

  it "é inválido sem valor pago" do
    pagamento = FaturaPagamento.new(cartao: cartao, mes_referencia: Date.current, valor_pago: nil, data_pagamento: Date.current)

    expect(pagamento).not_to be_valid
  end

  it "é inválido sem data de pagamento" do
    pagamento = FaturaPagamento.new(cartao: cartao, mes_referencia: Date.current, valor_pago: 500, data_pagamento: nil)

    expect(pagamento).not_to be_valid
  end

  it "é inválido com dois pagamentos para o mesmo cartão e mês" do
    FaturaPagamento.create!(cartao: cartao, mes_referencia: Date.new(2026, 7, 1), valor_pago: 500, data_pagamento: Date.current)
    duplicado = FaturaPagamento.new(cartao: cartao, mes_referencia: Date.new(2026, 7, 20), valor_pago: 400, data_pagamento: Date.current)

    expect(duplicado).not_to be_valid
  end
end
