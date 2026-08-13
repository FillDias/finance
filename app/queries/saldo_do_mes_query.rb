# Saldo = Entradas - Saídas. Não inclui Aporte (ver CONTEXT.md — Renda,
# Despesa e Aporte são três blocos independentes do fluxo de caixa).
class SaldoDoMesQuery < ApplicationQuery
  def initialize(mes: Date.current)
    @mes = mes
  end

  def call
    EntradasDoMesQuery.call(mes: @mes) - SaidasDoMesQuery.call(mes: @mes)
  end
end
