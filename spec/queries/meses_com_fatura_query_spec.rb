require "rails_helper"

RSpec.describe MesesComFaturaQuery do
  let(:credor) { Credor.create!(nome: "Nubank") }
  let(:cartao) { Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 6, 1)) }

  it "combina meses de saldo herdado e de parcelas, sem repetir e em ordem" do
    SaldoHerdado.create!(cartao: cartao, mes_referencia: Date.new(2026, 3, 1), valor_total: 500)
    CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 7, 3), valor_total: 300, parcelado: true, numero_parcelas: 2)

    meses = MesesComFaturaQuery.call(cartao: cartao)

    expect(meses).to eq([ Date.new(2026, 3, 1), Date.new(2026, 7, 1), Date.new(2026, 8, 1) ])
  end

  it "não repete o mês quando saldo herdado e parcela caem no mesmo mês" do
    SaldoHerdado.create!(cartao: cartao, mes_referencia: Date.new(2026, 7, 1), valor_total: 500)
    CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 7, 3), valor_total: 300, parcelado: false)

    expect(MesesComFaturaQuery.call(cartao: cartao)).to eq([ Date.new(2026, 7, 1) ])
  end

  it "retorna lista vazia para um cartão sem nenhum lançamento" do
    expect(MesesComFaturaQuery.call(cartao: cartao)).to eq([])
  end
end
