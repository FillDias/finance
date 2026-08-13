class EntradasDoMesQuery < ApplicationQuery
  def initialize(mes: Date.current)
    @mes = mes.to_date.beginning_of_month
  end

  def call
    Renda.where(data: @mes..@mes.end_of_month).sum(:valor)
  end
end
