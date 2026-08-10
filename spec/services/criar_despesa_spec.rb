require "rails_helper"

RSpec.describe CriarDespesa do
  let(:categoria) { Categoria.create!(nome: "Alimentação") }

  it "cria a despesa e retorna sucesso quando os dados são válidos" do
    resultado = CriarDespesa.call(
      valor: 80, data: Date.current, categoria_id: categoria.id, tipo: "variavel", forma_pagamento: "dinheiro"
    )

    expect(resultado).to be_sucesso
    expect(resultado.valor).to be_persisted
    expect(Despesa.count).to eq(1)
  end

  it "não cria e retorna erro quando despesa fixa não tem dia de vencimento" do
    resultado = CriarDespesa.call(
      valor: 120, data: Date.current, categoria_id: categoria.id, tipo: "fixa", forma_pagamento: "boleto"
    )

    expect(resultado).to be_erro
    expect(Despesa.count).to eq(0)
  end
end
