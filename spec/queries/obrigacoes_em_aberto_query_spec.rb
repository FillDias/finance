require "rails_helper"

RSpec.describe ObrigacoesEmAbertoQuery do
  let(:credor) { Credor.create!(nome: "Nubank") }
  let(:cartao) { Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 1, 1)) }

  it "soma obrigações pendentes e atrasadas" do
    SaldoHerdado.create!(cartao: cartao, mes_referencia: Date.new(2026, 3, 1), valor_total: 500)
    CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.current - 40, valor_total: 300, parcelado: false)

    expect(ObrigacoesEmAbertoQuery.call).to eq(800.to_d)
  end

  it "não conta obrigações já pagas" do
    resultado = CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.current, valor_total: 300, parcelado: false)
    resultado.valor.parcelas.first.update!(status: :paga)

    expect(ObrigacoesEmAbertoQuery.call).to eq(0)
  end

  it "retorna zero quando não há obrigações" do
    expect(ObrigacoesEmAbertoQuery.call).to eq(0)
  end
end
