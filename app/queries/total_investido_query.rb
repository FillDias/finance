class TotalInvestidoQuery < ApplicationQuery
  def call
    Aporte.joins(:investimento).merge(Investimento.ativo).sum(:valor)
  end
end
