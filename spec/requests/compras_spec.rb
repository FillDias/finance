require "rails_helper"

RSpec.describe "Compras", type: :request do
  let(:credor) { Credor.create!(nome: "Nubank") }
  let(:cartao) { Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 6, 1)) }

  describe "DELETE /cartoes/:cartao_id/compras/:id" do
    it "remove a compra e volta pra página do cartão quando não há Referer" do
      resultado = CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 7, 1), valor_total: 100, parcelado: false)
      compra = resultado.valor

      delete cartao_compra_path(cartao, compra)

      expect(Compra.exists?(compra.id)).to be false
      expect(response).to redirect_to(cartao_path(cartao))
    end

    it "volta pra página de origem (ex.: /despesas) quando há Referer" do
      resultado = CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 7, 1), valor_total: 100, parcelado: false)
      compra = resultado.valor

      delete cartao_compra_path(cartao, compra), headers: { "HTTP_REFERER" => despesas_path }

      expect(response).to redirect_to(despesas_path)
    end
  end
end
