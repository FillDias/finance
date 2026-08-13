require "rails_helper"

RSpec.describe VencimentoSaldoHerdado do
  let(:credor) { Credor.create!(nome: "Nubank") }

  it "usa o dia de vencimento do cartão, no mês de referência do saldo" do
    cartao = Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 1, 1))
    saldo = SaldoHerdado.create!(cartao: cartao, mes_referencia: Date.new(2026, 7, 1), valor_total: 800)

    expect(VencimentoSaldoHerdado.para(saldo)).to eq(Date.new(2026, 7, 12))
  end

  it "usa o último dia do mês quando o dia de vencimento do cartão não existe naquele mês" do
    cartao = Cartao.create!(nome: "Gold", credor: credor, limite_total: 3000, dia_fechamento: 25, dia_vencimento: 31, data_corte: Date.new(2026, 1, 1))
    saldo = SaldoHerdado.create!(cartao: cartao, mes_referencia: Date.new(2026, 2, 1), valor_total: 500)

    expect(VencimentoSaldoHerdado.para(saldo)).to eq(Date.new(2026, 2, 28))
  end
end
