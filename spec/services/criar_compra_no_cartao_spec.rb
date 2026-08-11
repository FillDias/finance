require "rails_helper"

RSpec.describe CriarCompraNoCartao do
  let(:credor) { Credor.create!(nome: "Nubank") }
  let(:cartao) do
    Cartao.create!(
      nome: "Ultravioleta", credor: credor, limite_total: 5000,
      dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 7, 1)
    )
  end

  it "cria a compra à vista com uma única parcela" do
    resultado = CriarCompraNoCartao.call(
      cartao_id: cartao.id, data_compra: Date.new(2026, 7, 10), valor_total: 250, parcelado: false
    )

    expect(resultado).to be_sucesso
    compra = resultado.valor
    expect(compra).to be_persisted
    expect(compra.parcelas.count).to eq(1)
    expect(compra.parcelas.first.valor).to eq(250.to_d)
  end

  it "cria a compra parcelada com N parcelas geradas automaticamente" do
    resultado = CriarCompraNoCartao.call(
      cartao_id: cartao.id, data_compra: Date.new(2026, 7, 10), valor_total: 1000, parcelado: true, numero_parcelas: 3
    )

    expect(resultado).to be_sucesso
    compra = resultado.valor
    expect(compra.parcelas.count).to eq(3)
    expect(compra.parcelas.order(:data_vencimento).pluck(:valor)).to eq([ 333.33.to_d, 333.33.to_d, 333.34.to_d ])
  end

  it "rejeita compra feita antes da data de corte do cartão" do
    resultado = CriarCompraNoCartao.call(
      cartao_id: cartao.id, data_compra: Date.new(2026, 6, 20), valor_total: 100, parcelado: false
    )

    expect(resultado).to be_erro
    expect(Compra.count).to eq(0)
  end

  it "aceita compra feita exatamente na data de corte" do
    resultado = CriarCompraNoCartao.call(
      cartao_id: cartao.id, data_compra: Date.new(2026, 7, 1), valor_total: 100, parcelado: false
    )

    expect(resultado).to be_sucesso
  end

  it "rejeita e não persiste nada quando a compra é inválida" do
    resultado = CriarCompraNoCartao.call(
      cartao_id: cartao.id, data_compra: Date.new(2026, 7, 10), valor_total: -50, parcelado: false
    )

    expect(resultado).to be_erro
    expect(Compra.count).to eq(0)
    expect(Parcela.count).to eq(0)
  end

  it "retorna erro quando o cartão não existe" do
    resultado = CriarCompraNoCartao.call(
      cartao_id: -1, data_compra: Date.new(2026, 7, 10), valor_total: 100, parcelado: false
    )

    expect(resultado).to be_erro
  end
end
