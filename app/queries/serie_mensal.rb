# Roda um bloco uma vez por mês nos últimos N meses (incluindo o atual) e
# devolve {mes:, valor:} pra cada um — usado pelos sparklines de KPI que
# têm uma query naturalmente parametrizável por mês (Entradas, Saídas,
# Saldo). Não serve pra métricas "foto do agora" como Dívida Total, que
# não têm como ser recalculadas retroativamente sem um histórico que o
# sistema não guarda.
class SerieMensal < ApplicationQuery
  def initialize(meses: 6, &bloco_valor_do_mes)
    @meses = meses
    @bloco = bloco_valor_do_mes
  end

  def call
    (@meses - 1).downto(0).map do |offset|
      mes = (Date.current - offset.months).beginning_of_month
      { mes: mes, valor: @bloco.call(mes) }
    end
  end
end
