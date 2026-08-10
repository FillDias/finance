require "rails_helper"

RSpec.describe ExcluirDespesa do
  it "remove a despesa e retorna sucesso" do
    categoria = Categoria.create!(nome: "Alimentação")
    despesa = Despesa.create!(valor: 50, data: Date.current, categoria: categoria, tipo: :variavel, forma_pagamento: :dinheiro)

    resultado = ExcluirDespesa.call(despesa: despesa)

    expect(resultado).to be_sucesso
    expect(Despesa.exists?(despesa.id)).to be false
  end
end
