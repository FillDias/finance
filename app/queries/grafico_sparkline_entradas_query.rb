class GraficoSparklineEntradasQuery < ApplicationQuery
  def initialize(meses: 6)
    @meses = meses
  end

  def call
    valores = SerieMensal.call(meses: @meses) { |mes| EntradasDoMesQuery.call(mes: mes) }.map { |item| item[:valor] }

    SparklineOption.para(valores)
  end
end
