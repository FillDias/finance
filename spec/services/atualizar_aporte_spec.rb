require "rails_helper"

RSpec.describe AtualizarAporte do
  let(:tipo) { TipoInvestimento.create!(nome: "CDB") }
  let(:investimento) { Investimento.create!(tipo_investimento: tipo, instituicao: "Nubank", taxa_rendimento: 1.1, periodicidade_taxa: :mensal, status: :ativo) }

  it "atualiza o aporte e retorna sucesso quando os dados são válidos" do
    aporte = Aporte.create!(investimento: investimento, valor: 500, data: Date.new(2026, 1, 1))

    resultado = AtualizarAporte.call(aporte: aporte, valor: 700, data: Date.new(2026, 1, 5))

    expect(resultado).to be_sucesso
    expect(aporte.reload.valor).to eq(700.to_d)
  end

  it "não atualiza e retorna erro quando os dados são inválidos" do
    aporte = Aporte.create!(investimento: investimento, valor: 500, data: Date.new(2026, 1, 1))

    resultado = AtualizarAporte.call(aporte: aporte, valor: -5, data: Date.new(2026, 1, 5))

    expect(resultado).to be_erro
    expect(aporte.reload.valor).to eq(500.to_d)
  end
end
