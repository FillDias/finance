require "rails_helper"

RSpec.describe QuitarSaldoHerdado do
  let(:credor) { Credor.create!(nome: "Nubank") }
  let(:cartao) { Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 6, 1)) }
  let(:saldo) { SaldoHerdado.create!(cartao: cartao, mes_referencia: Date.new(2026, 3, 1), valor_total: 1200) }

  it "marca o saldo herdado como quitado antecipadamente" do
    resultado = QuitarSaldoHerdado.call(saldo_herdado: saldo, valor_pago: 1000, data_pagamento: Date.new(2026, 2, 15))

    expect(resultado).to be_sucesso
    expect(saldo.reload.quitado_antecipadamente?).to be true
    expect(saldo.valor_pago).to eq(1000)
  end

  it "permite valor pago menor que o valor total previsto (negociação)" do
    resultado = QuitarSaldoHerdado.call(saldo_herdado: saldo, valor_pago: 800, data_pagamento: Date.current)

    expect(resultado).to be_sucesso
    expect(saldo.reload.valor_pago).to eq(800)
  end

  it "retorna erro quando só um dos dois campos é enviado" do
    resultado = QuitarSaldoHerdado.call(saldo_herdado: saldo, valor_pago: 1000, data_pagamento: nil)

    expect(resultado).to be_erro
    expect(saldo.reload.valor_pago).to be_nil
  end
end
