require "rails_helper"

RSpec.describe AtualizarInvestimento do
  let(:tipo) { TipoInvestimento.create!(nome: "CDB") }
  let(:outro_tipo) { TipoInvestimento.create!(nome: "Tesouro Direto") }

  it "atualiza o investimento e retorna sucesso quando os dados são válidos" do
    investimento = Investimento.create!(tipo_investimento: tipo, instituicao: "Nubank", taxa_rendimento: 1.1, periodicidade_taxa: :mensal, status: :ativo)

    resultado = AtualizarInvestimento.call(
      investimento: investimento, tipo_investimento_id: outro_tipo.id, instituicao: "XP", taxa_rendimento: 12.5, periodicidade_taxa: "anual"
    )

    expect(resultado).to be_sucesso
    expect(investimento.reload.instituicao).to eq("XP")
    expect(investimento.tipo_investimento_id).to eq(outro_tipo.id)
  end

  it "não atualiza e retorna erro quando os dados são inválidos" do
    investimento = Investimento.create!(tipo_investimento: tipo, instituicao: "Nubank", taxa_rendimento: 1.1, periodicidade_taxa: :mensal, status: :ativo)

    resultado = AtualizarInvestimento.call(
      investimento: investimento, tipo_investimento_id: tipo.id, instituicao: "", taxa_rendimento: 1.1, periodicidade_taxa: "mensal"
    )

    expect(resultado).to be_erro
    expect(investimento.reload.instituicao).to eq("Nubank")
  end
end
