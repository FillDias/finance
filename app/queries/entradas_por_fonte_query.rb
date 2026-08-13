# Uma linha por (mês, fonte) nos últimos N meses — a Query de gráfico
# reshapea isso em séries empilhadas por fonte.
class EntradasPorFonteQuery < ApplicationQuery
  def initialize(meses: 6)
    @meses = meses
  end

  def call
    inicio = (@meses - 1).months.ago.to_date.beginning_of_month
    fim = Date.current.end_of_month

    Renda.where(data: inicio..fim)
         .group(:fonte, Arel.sql("date_trunc('month', data)"))
         .sum(:valor)
         .map { |(fonte, mes), valor| { fonte: fonte, mes: mes.to_date, valor: valor } }
  end
end
