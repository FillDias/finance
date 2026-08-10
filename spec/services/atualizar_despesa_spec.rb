require "rails_helper"

RSpec.describe AtualizarDespesa do
  let(:categoria) { Categoria.create!(nome: "Alimentação") }

  it "atualiza a despesa e retorna sucesso quando os dados são válidos" do
    despesa = Despesa.create!(valor: 50, data: Date.current, categoria: categoria, tipo: :variavel, forma_pagamento: :dinheiro)

    resultado = AtualizarDespesa.call(
      despesa: despesa, valor: 60, data: Date.current, categoria_id: categoria.id, tipo: "fixa", forma_pagamento: "boleto", dia_vencimento: 5
    )

    expect(resultado).to be_sucesso
    expect(despesa.reload.valor).to eq(60)
    expect(despesa.fixa?).to be true
  end

  it "não atualiza e retorna erro quando os dados são inválidos" do
    despesa = Despesa.create!(valor: 50, data: Date.current, categoria: categoria, tipo: :variavel, forma_pagamento: :dinheiro)

    resultado = AtualizarDespesa.call(
      despesa: despesa, valor: 60, data: Date.current, categoria_id: categoria.id, tipo: "fixa", forma_pagamento: "boleto"
    )

    expect(resultado).to be_erro
    expect(despesa.reload.valor).to eq(50)
  end
end
