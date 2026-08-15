require "rails_helper"

RSpec.describe "Despesas", type: :request do
  let(:categoria) { Categoria.create!(nome: "Alimentação") }

  describe "DELETE /despesas/:id" do
    it "remove a despesa e volta pra /despesas quando não há Referer" do
      despesa = Despesa.create!(valor: 50, data: Date.current, categoria: categoria, tipo: :variavel, forma_pagamento: :dinheiro)

      delete despesa_path(despesa)

      expect(Despesa.exists?(despesa.id)).to be false
      expect(response).to redirect_to(despesas_path)
    end

    it "volta pra página de origem (ex.: o Painel) quando há Referer, pra funcionar dentro do turbo-frame de lá" do
      despesa = Despesa.create!(valor: 50, data: Date.current, categoria: categoria, tipo: :variavel, forma_pagamento: :dinheiro)

      delete despesa_path(despesa), headers: { "HTTP_REFERER" => root_path(mes: "2026-07-01") }

      expect(response).to redirect_to(root_path(mes: "2026-07-01"))
    end
  end
end
