require "rails_helper"

RSpec.describe ComparacaoPeriodoQuery do
  it "compara o valor do mês com o valor do mês anterior via o bloco recebido" do
    valores = { Date.new(2026, 8, 1) => 1000, Date.new(2026, 7, 1) => 800 }

    comparacao = ComparacaoPeriodoQuery.call(mes: Date.new(2026, 8, 1)) { |mes| valores.fetch(mes) }

    expect(comparacao.atual).to eq(1000)
    expect(comparacao.anterior).to eq(800)
    expect(comparacao.delta).to eq(200)
    expect(comparacao.percentual).to eq(25)
  end

  it "percentual é nil quando o mês anterior é zero, pra não dividir por zero" do
    comparacao = ComparacaoPeriodoQuery.call(mes: Date.new(2026, 8, 1)) { |mes| mes.month == 8 ? 500 : 0 }

    expect(comparacao.percentual).to be_nil
  end
end
