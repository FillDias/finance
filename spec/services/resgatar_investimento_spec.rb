require "rails_helper"

RSpec.describe ResgatarInvestimento do
  let(:tipo) { TipoInvestimento.create!(nome: "CDB") }
  let(:investimento) { Investimento.create!(tipo_investimento: tipo, instituicao: "Nubank", taxa_rendimento: 1.1, periodicidade_taxa: :mensal, status: :ativo) }

  it "marca o investimento como resgatado com valor e data" do
    resultado = ResgatarInvestimento.call(investimento: investimento, valor_resgatado: 1050, data_resgate: Date.new(2026, 12, 1))

    expect(resultado).to be_sucesso
    expect(investimento.reload.resgatado?).to be true
    expect(investimento.valor_resgatado).to eq(1050.to_d)
    expect(investimento.data_resgate).to eq(Date.new(2026, 12, 1))
  end

  it "permite valor resgatado diferente da soma aportada (rendimento ou perda)" do
    resultado = ResgatarInvestimento.call(investimento: investimento, valor_resgatado: 980, data_resgate: Date.current)

    expect(resultado).to be_sucesso
    expect(investimento.reload.valor_resgatado).to eq(980.to_d)
  end

  it "retorna erro e não altera o investimento quando o valor resgatado é inválido" do
    resultado = ResgatarInvestimento.call(investimento: investimento, valor_resgatado: -10, data_resgate: Date.current)

    expect(resultado).to be_erro
    expect(investimento.reload.ativo?).to be true
  end
end
