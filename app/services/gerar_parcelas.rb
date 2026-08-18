class GerarParcelas < ApplicationService
  def initialize(valor_total:, numero_parcelas:, data_compra:, dia_fechamento:, dia_vencimento:)
    @valor_total = valor_total
    @numero_parcelas = numero_parcelas
    @data_compra = data_compra
    @dia_fechamento = dia_fechamento
    @dia_vencimento = dia_vencimento
  end

  def call
    DividirParcelas.call(
      valor_total: @valor_total, numero_parcelas: @numero_parcelas,
      mes_base: mes_do_primeiro_vencimento, dia_vencimento: @dia_vencimento
    )
  end

  private

  # Etapa 1: em qual mês a compra fecha. Antes do dia de fechamento cai no
  # ciclo do próprio mês; no dia de fechamento ou depois, já cai no ciclo
  # do mês seguinte.
  def mes_de_fechamento
    if @data_compra.day < @dia_fechamento
      @data_compra.beginning_of_month
    else
      (@data_compra + 1.month).beginning_of_month
    end
  end

  # Etapa 2: em qual mês o vencimento daquele fechamento cai — não é
  # sempre o mesmo mês do fechamento. Ex.: fecha dia 29, vence dia 8 — o
  # dia 8 já passou dentro do próprio mês de fechamento, então esse
  # vencimento só acontece no mês seguinte. Só cai no mesmo mês do
  # fechamento quando o dia de vencimento ainda não passou (dia_vencimento
  # >= dia_fechamento).
  def mes_do_primeiro_vencimento
    if @dia_vencimento < @dia_fechamento
      mes_de_fechamento + 1.month
    else
      mes_de_fechamento
    end
  end
end
