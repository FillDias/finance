class GraficoSparklineSaidasQuery < ApplicationQuery
  def initialize(meses: 6, categoria_id: nil, cartao_id: nil)
    @meses = meses
    @categoria_id = categoria_id
    @cartao_id = cartao_id
  end

  def call
    valores = SerieMensal.call(meses: @meses) { |mes| SaidasDoMesQuery.call(mes: mes, categoria_id: @categoria_id, cartao_id: @cartao_id) }
                          .map { |item| item[:valor] }

    SparklineOption.para(valores)
  end
end
