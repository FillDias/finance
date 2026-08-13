require "rails_helper"

RSpec.describe SerieMensal do
  it "roda o bloco uma vez por mês, do mais antigo pro mais recente, incluindo o atual" do
    chamadas = []

    SerieMensal.call(meses: 3) { |mes| chamadas << mes }

    expect(chamadas).to eq([ 2.months.ago.to_date.beginning_of_month, 1.month.ago.to_date.beginning_of_month, Date.current.beginning_of_month ])
  end

  it "retorna o mês e o valor calculado pelo bloco" do
    serie = SerieMensal.call(meses: 2) { |mes| mes.day }

    expect(serie).to eq([
      { mes: 1.month.ago.to_date.beginning_of_month, valor: 1 },
      { mes: Date.current.beginning_of_month, valor: 1 }
    ])
  end
end
