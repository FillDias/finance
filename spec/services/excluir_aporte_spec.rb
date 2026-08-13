require "rails_helper"

RSpec.describe ExcluirAporte do
  it "remove o aporte e retorna sucesso" do
    tipo = TipoInvestimento.create!(nome: "CDB")
    investimento = Investimento.create!(tipo_investimento: tipo, instituicao: "Nubank", taxa_rendimento: 1.1, periodicidade_taxa: :mensal, status: :ativo)
    aporte = Aporte.create!(investimento: investimento, valor: 500, data: Date.current)

    resultado = ExcluirAporte.call(aporte: aporte)

    expect(resultado).to be_sucesso
    expect(Aporte.exists?(aporte.id)).to be false
  end
end
