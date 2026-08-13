# "Atrelados a CDI" é lido literalmente como Tipo de Investimento = "CDI"
# (um dos 8 tipos semeados) — não existe hoje um campo separado marcando
# um CDB como "% do CDI", então esse é o único vínculo que o modelo atual
# consegue expressar sem inventar um campo novo fora do escopo do ticket.
class ComparacaoCdiQuery < ApplicationQuery
  TIPO_CDI = "CDI"

  def call
    taxa_cdi = TaxaCdi.atual.valor

    investimentos_atrelados_a_cdi.map do |investimento|
      ComparacaoCdi.new(investimento: investimento, taxa_anualizada: taxa_anualizada(investimento), taxa_cdi: taxa_cdi)
    end
  end

  private

  def investimentos_atrelados_a_cdi
    Investimento.joins(:tipo_investimento).where(tipos_investimento: { nome: TIPO_CDI })
  end

  # Mesma regra simples (sem compor) já usada pra rendimento estimado —
  # só multiplica a taxa mensal por 12 pra comparar com o CDI, que é
  # sempre expresso ao ano.
  def taxa_anualizada(investimento)
    investimento.mensal? ? investimento.taxa_rendimento * 12 : investimento.taxa_rendimento
  end
end
