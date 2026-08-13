require "rails_helper"

RSpec.describe ValorVencidoNoMesQuery do
  it "soma o valor de toda Obrigação vencida no mês, independente do status" do
    categoria = Categoria.create!(nome: "Casa")
    Despesa.create!(valor: 300, data: Date.current, categoria: categoria, tipo: :fixa, forma_pagamento: :boleto, dia_vencimento: 10)
    Despesa.create!(valor: 200, data: Date.current - 2.months, categoria: categoria, tipo: :fixa, forma_pagamento: :boleto, dia_vencimento: 10)

    expect(ValorVencidoNoMesQuery.call(mes: Date.current)).to eq(300.to_d)
  end

  it "zero quando não há obrigação vencendo no mês" do
    expect(ValorVencidoNoMesQuery.call(mes: Date.current)).to eq(0)
  end
end
