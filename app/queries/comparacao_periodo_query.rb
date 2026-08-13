# Genérica: recebe o mês atual e um bloco que sabe calcular o valor de
# qualquer mês (mesma convenção de bloco do SerieMensal), compara com o mês
# anterior.
class ComparacaoPeriodoQuery < ApplicationQuery
  def initialize(mes:, &bloco_valor_do_mes)
    @mes = mes.to_date.beginning_of_month
    @bloco = bloco_valor_do_mes
  end

  def call
    ComparacaoPeriodo.new(atual: @bloco.call(@mes), anterior: @bloco.call(@mes - 1.month))
  end
end
