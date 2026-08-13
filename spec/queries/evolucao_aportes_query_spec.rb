require "rails_helper"

RSpec.describe EvolucaoAportesQuery do
  let(:tipo) { TipoInvestimento.create!(nome: "CDB") }
  let(:investimento) { Investimento.create!(tipo_investimento: tipo, instituicao: "Nubank", taxa_rendimento: 1.1, periodicidade_taxa: :mensal, status: :ativo) }

  it "agrupa aportes por mês, com o valor do mês e o acumulado" do
    Aporte.create!(investimento: investimento, valor: 500, data: Date.new(2026, 1, 10))
    Aporte.create!(investimento: investimento, valor: 300, data: Date.new(2026, 1, 20))
    Aporte.create!(investimento: investimento, valor: 200, data: Date.new(2026, 2, 5))

    serie = EvolucaoAportesQuery.call

    expect(serie.map { |item| item[:valor_mes] }).to eq([ 800.to_d, 200.to_d ])
    expect(serie.map { |item| item[:acumulado] }).to eq([ 800.to_d, 1000.to_d ])
  end

  it "o acumulado reflete a história inteira, mesmo fora da janela de meses exibida" do
    Aporte.create!(investimento: investimento, valor: 1000, data: Date.current - 20.months)
    Aporte.create!(investimento: investimento, valor: 200, data: Date.current)

    serie = EvolucaoAportesQuery.call(meses: 12)

    expect(serie.size).to eq(12)
    expect(serie.first[:acumulado]).to eq(1000.to_d)
    expect(serie.last[:acumulado]).to eq(1200.to_d)
  end

  it "retorna lista vazia quando não há aportes" do
    expect(EvolucaoAportesQuery.call).to eq([])
  end
end
