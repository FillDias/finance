require "rails_helper"

RSpec.describe UtilizacaoLimiteQuery do
  let(:credor) { Credor.create!(nome: "Nubank") }
  let(:cartao) { Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 1000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 6, 1)) }

  it "divide o saldo restante pelo limite total" do
    CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 7, 3), valor_total: 250, parcelado: false)

    expect(UtilizacaoLimiteQuery.call(cartao: cartao)).to eq(0.25.to_d)
  end

  it "retorna zero para um cartão sem saldo restante" do
    expect(UtilizacaoLimiteQuery.call(cartao: cartao)).to eq(0)
  end
end
