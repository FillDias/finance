require "rails_helper"

RSpec.describe GraficoSaldoRestantePorCartaoQuery do
  let(:credor) { Credor.create!(nome: "Nubank") }
  let(:cartao) { Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 1, 1)) }

  it "monta uma fatia por cartão com dívida, com tooltip mostrando a composição" do
    SaldoHerdado.create!(cartao: cartao, mes_referencia: Date.current.beginning_of_month, valor_total: 800)
    CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.current, valor_total: 300, parcelado: false)

    opcao = GraficoSaldoRestantePorCartaoQuery.call
    fatia = opcao[:series].first[:data].first

    expect(fatia[:name]).to eq("Ultravioleta")
    expect(fatia[:value]).to eq(1100.to_d)
    expect(fatia[:chave]).to eq(cartao.id)
    expect(fatia[:tooltip][:formatter]).to include("Saldo herdado").and include("Parcelas em aberto")
  end

  it "não quebra quando não há dívida" do
    opcao = GraficoSaldoRestantePorCartaoQuery.call

    expect(opcao[:series].first[:data]).to eq([])
  end
end
