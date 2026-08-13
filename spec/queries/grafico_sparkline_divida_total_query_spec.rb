require "rails_helper"

RSpec.describe GraficoSparklineDividaTotalQuery do
  let(:credor) { Credor.create!(nome: "Nubank") }
  let(:cartao) { Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 1, 1)) }

  it "monta a série de valor vencido por mês, nos últimos meses" do
    CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.current - 40, valor_total: 300, parcelado: false)

    opcao = GraficoSparklineDividaTotalQuery.call(meses: 6)

    expect(opcao[:series].first[:data].size).to eq(6)
    expect(opcao[:series].first[:data].sum).to eq(300.to_d)
  end

  it "não quebra quando não há obrigações" do
    opcao = GraficoSparklineDividaTotalQuery.call(meses: 6)

    expect(opcao[:series].first[:data]).to eq(Array.new(6, 0.to_d))
  end
end
