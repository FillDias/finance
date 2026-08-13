class EvolucaoAportesQuery < ApplicationQuery
  # somente_ativos existe pro sparkline do KPI "Total investido" (que é
  # ativo-only, via TotalInvestidoQuery) poder mostrar a mesma tendência
  # que o número ao lado dele — sem isso, um aporte de um investimento já
  # resgatado inflava a linha além do total exibido. O padrão (false)
  # continua mostrando toda a atividade histórica de aportes, pro
  # gráfico "Evolução dos aportes" da tela — a AC dessa query, ao
  # contrário das outras três, não pede filtro por status.
  def initialize(meses: 12, somente_ativos: false)
    @meses = meses
    @somente_ativos = somente_ativos
  end

  def call
    # O acumulado precisa refletir a história inteira, não só a janela
    # exibida — senão um usuário com aportes antigos veria a linha
    # "reiniciar" perto de zero no início da janela dos últimos N meses.
    acumulado = 0.to_d

    serie_completa = aportes_escopados.group_by_month(:data).sum(:valor).map do |mes, valor_mes|
      acumulado += valor_mes
      { mes: mes, valor_mes: valor_mes, acumulado: acumulado }
    end

    serie_completa.last(@meses)
  end

  private

  def aportes_escopados
    return Aporte unless @somente_ativos

    Aporte.joins(:investimento).merge(Investimento.ativo)
  end
end
