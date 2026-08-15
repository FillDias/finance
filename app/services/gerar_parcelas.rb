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
      mes_base: mes_da_primeira_fatura, dia_vencimento: @dia_vencimento
    )
  end

  private

  # Uma compra feita antes do dia de fechamento cai na fatura do próprio mês;
  # no dia de fechamento ou depois, já cai na fatura do mês seguinte.
  def mes_da_primeira_fatura
    if @data_compra.day < @dia_fechamento
      @data_compra.beginning_of_month
    else
      (@data_compra + 1.month).beginning_of_month
    end
  end
end
