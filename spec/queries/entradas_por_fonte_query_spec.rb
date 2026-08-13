require "rails_helper"

RSpec.describe EntradasPorFonteQuery do
  it "agrupa entradas por mês e fonte, dentro da janela de meses pedida" do
    Renda.create!(valor: 1000, data: Date.current.beginning_of_month, fonte: "Salário")
    Renda.create!(valor: 300, data: Date.current.beginning_of_month, fonte: "Freela")
    Renda.create!(valor: 500, data: Date.current.beginning_of_month - 3.months, fonte: "Salário")

    itens = EntradasPorFonteQuery.call(meses: 2)

    expect(itens).to contain_exactly(
      { fonte: "Salário", mes: Date.current.beginning_of_month, valor: 1000.to_d },
      { fonte: "Freela", mes: Date.current.beginning_of_month, valor: 300.to_d }
    )
  end
end
