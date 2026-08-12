class AtualizarInvestimento < ApplicationService
  def initialize(investimento:, tipo_investimento_id:, instituicao:, taxa_rendimento:, periodicidade_taxa:, data_vencimento: nil)
    @investimento = investimento
    @tipo_investimento_id = tipo_investimento_id
    @instituicao = instituicao
    @taxa_rendimento = taxa_rendimento
    @periodicidade_taxa = periodicidade_taxa
    @data_vencimento = data_vencimento
  end

  def call
    if @investimento.update(
      tipo_investimento_id: @tipo_investimento_id,
      instituicao: @instituicao,
      taxa_rendimento: @taxa_rendimento,
      periodicidade_taxa: @periodicidade_taxa,
      data_vencimento: @data_vencimento
    )
      Resultado.sucesso(valor: @investimento)
    else
      Resultado.erro(*@investimento.errors.full_messages, valor: @investimento)
    end
  end
end
