require "rails_helper"

RSpec.describe ExcluirCompra do
  it "remove a compra e suas parcelas" do
    credor = Credor.create!(nome: "Nubank")
    cartao = Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 6, 1))
    resultado = CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 7, 1), valor_total: 300, parcelado: true, numero_parcelas: 3)
    compra = resultado.valor

    ExcluirCompra.call(compra: compra)

    expect(Compra.exists?(compra.id)).to be false
    expect(Parcela.where(origem: compra).count).to eq(0)
  end
end
