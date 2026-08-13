class DistribuicaoPorTipoQuery < ApplicationQuery
  def call
    Aporte.joins(investimento: :tipo_investimento)
          .merge(Investimento.ativo)
          .group("tipos_investimento.nome")
          .sum(:valor)
  end
end
