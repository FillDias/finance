class EvolucaoAportesQuery < ApplicationQuery
  def initialize(meses: 12)
    @meses = meses
  end

  def call
    # O acumulado precisa refletir a história inteira, não só a janela
    # exibida — senão um usuário com aportes antigos veria a linha
    # "reiniciar" perto de zero no início da janela dos últimos N meses.
    acumulado = 0.to_d

    serie_completa = Aporte.group_by_month(:data).sum(:valor).map do |mes, valor_mes|
      acumulado += valor_mes
      { mes: mes, valor_mes: valor_mes, acumulado: acumulado }
    end

    serie_completa.last(@meses)
  end
end
