class CriarInvestimento < ApplicationService
  def initialize(tipo_investimento_id:, instituicao:, taxa_rendimento:, periodicidade_taxa:, data_vencimento: nil)
    @tipo_investimento_id = tipo_investimento_id
    @instituicao = instituicao
    @taxa_rendimento = taxa_rendimento
    @periodicidade_taxa = periodicidade_taxa
    @data_vencimento = data_vencimento
  end

  def call
    investimento = Investimento.new(
      tipo_investimento_id: @tipo_investimento_id,
      instituicao: @instituicao,
      taxa_rendimento: @taxa_rendimento,
      periodicidade_taxa: @periodicidade_taxa,
      data_vencimento: @data_vencimento,
      status: :ativo
    )

    if investimento.save
      Resultado.sucesso(valor: investimento)
    else
      Resultado.erro(*investimento.errors.full_messages, valor: investimento)
    end
  end
end
