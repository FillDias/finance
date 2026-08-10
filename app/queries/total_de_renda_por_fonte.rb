class TotalDeRendaPorFonte < ApplicationQuery
  def initialize(ano:)
    @ano = ano
  end

  def call
    Renda.where(data: Date.new(@ano, 1, 1)..Date.new(@ano, 12, 31)).group(:fonte).sum(:valor)
  end
end
