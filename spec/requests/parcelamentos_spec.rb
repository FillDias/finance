require "rails_helper"

RSpec.describe "Parcelamentos", type: :request do
  describe "DELETE /parcelamentos/:id" do
    it "remove o parcelamento e volta pra página de origem" do
      categoria = Categoria.create!(nome: "Mercado")
      resultado = CriarParcelamento.call(
        valor_total: 300, numero_parcelas: 3, data: Date.new(2026, 7, 10),
        categoria_id: categoria.id, tipo: "variavel", forma_pagamento: "boleto"
      )
      parcelamento = resultado.valor

      delete parcelamento_path(parcelamento), headers: { "HTTP_REFERER" => root_path }

      expect(Parcelamento.exists?(parcelamento.id)).to be false
      expect(response).to redirect_to(root_path)
    end
  end
end
