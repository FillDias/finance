require "rails_helper"

RSpec.describe CriarAporte do
  let(:tipo) { TipoInvestimento.create!(nome: "CDB") }
  let(:investimento) { Investimento.create!(tipo_investimento: tipo, instituicao: "Nubank", taxa_rendimento: 1.1, periodicidade_taxa: :mensal, status: :ativo) }

  it "cria o aporte e retorna sucesso quando os dados são válidos" do
    resultado = CriarAporte.call(investimento_id: investimento.id, valor: 500, data: Date.current)

    expect(resultado).to be_sucesso
    expect(resultado.valor).to be_persisted
    expect(investimento.aportes.count).to eq(1)
  end

  it "não cria e retorna erro quando os dados são inválidos" do
    resultado = CriarAporte.call(investimento_id: investimento.id, valor: -10, data: Date.current)

    expect(resultado).to be_erro
    expect(Aporte.count).to eq(0)
  end
end
