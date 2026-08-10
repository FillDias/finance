require "rails_helper"

RSpec.describe Despesa, type: :model do
  let(:categoria) { Categoria.create!(nome: "Alimentação") }

  it "é válida como despesa variável sem dia de vencimento" do
    despesa = Despesa.new(valor: 50, data: Date.current, categoria: categoria, tipo: :variavel, forma_pagamento: :dinheiro)

    expect(despesa).to be_valid
  end

  it "é válida como despesa fixa com dia de vencimento" do
    despesa = Despesa.new(valor: 120, data: Date.current, categoria: categoria, tipo: :fixa, forma_pagamento: :boleto, dia_vencimento: 10)

    expect(despesa).to be_valid
  end

  it "é inválida como despesa fixa sem dia de vencimento" do
    despesa = Despesa.new(valor: 120, data: Date.current, categoria: categoria, tipo: :fixa, forma_pagamento: :boleto)

    expect(despesa).not_to be_valid
    expect(despesa.errors[:dia_vencimento]).not_to be_empty
  end

  it "é inválida com dia de vencimento fora do intervalo 1..31" do
    despesa = Despesa.new(valor: 120, data: Date.current, categoria: categoria, tipo: :fixa, forma_pagamento: :boleto, dia_vencimento: 32)

    expect(despesa).not_to be_valid
    expect(despesa.errors[:dia_vencimento]).not_to be_empty
  end

  it "é inválida sem categoria" do
    despesa = Despesa.new(valor: 50, data: Date.current, categoria: nil, tipo: :variavel, forma_pagamento: :dinheiro)

    expect(despesa).not_to be_valid
  end

  it "é inválida com valor zero ou negativo" do
    despesa = Despesa.new(valor: 0, data: Date.current, categoria: categoria, tipo: :variavel, forma_pagamento: :dinheiro)

    expect(despesa).not_to be_valid
    expect(despesa.errors[:valor]).not_to be_empty
  end

  it "expõe rótulos legíveis para tipo e forma de pagamento" do
    despesa = Despesa.new(tipo: :variavel, forma_pagamento: :pix)

    expect(despesa.tipo_label).to eq("Variável")
    expect(despesa.forma_pagamento_label).to eq("PIX")
  end
end
