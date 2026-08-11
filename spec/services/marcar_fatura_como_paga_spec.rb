require "rails_helper"

RSpec.describe MarcarFaturaComoPaga do
  let(:credor) { Credor.create!(nome: "Nubank") }
  let(:cartao) { Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 6, 1)) }

  it "cria o registro de pagamento quando não existe um para o mês" do
    resultado = MarcarFaturaComoPaga.call(cartao_id: cartao.id, mes_referencia: "2026-07-20", valor_pago: 500, data_pagamento: Date.new(2026, 7, 11))

    expect(resultado).to be_sucesso
    expect(FaturaPagamento.count).to eq(1)
    expect(FaturaPagamento.first.mes_referencia).to eq(Date.new(2026, 7, 1))
  end

  it "atualiza o registro existente em vez de duplicar quando chamado de novo para o mesmo mês" do
    MarcarFaturaComoPaga.call(cartao_id: cartao.id, mes_referencia: Date.new(2026, 7, 1), valor_pago: 500, data_pagamento: Date.new(2026, 7, 11))
    resultado = MarcarFaturaComoPaga.call(cartao_id: cartao.id, mes_referencia: Date.new(2026, 7, 15), valor_pago: 600, data_pagamento: Date.new(2026, 7, 12))

    expect(resultado).to be_sucesso
    expect(FaturaPagamento.count).to eq(1)
    expect(FaturaPagamento.first.valor_pago).to eq(600.to_d)
  end

  it "retorna erro quando o mês de referência é inválido" do
    resultado = MarcarFaturaComoPaga.call(cartao_id: cartao.id, mes_referencia: "não é uma data", valor_pago: 500, data_pagamento: Date.current)

    expect(resultado).to be_erro
    expect(FaturaPagamento.count).to eq(0)
  end

  it "retorna erro quando o valor pago é inválido" do
    resultado = MarcarFaturaComoPaga.call(cartao_id: cartao.id, mes_referencia: Date.new(2026, 7, 1), valor_pago: -10, data_pagamento: Date.current)

    expect(resultado).to be_erro
    expect(FaturaPagamento.count).to eq(0)
  end
end
