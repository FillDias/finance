class GerarParcelas < ApplicationService
  def initialize(valor_total:, numero_parcelas:, data_compra:, dia_fechamento:, dia_vencimento:)
    @valor_total = valor_total.to_d
    @numero_parcelas = numero_parcelas.to_i
    @data_compra = data_compra
    @dia_fechamento = dia_fechamento
    @dia_vencimento = dia_vencimento
  end

  def call
    valores = dividir_valor
    datas = calcular_datas_de_vencimento

    Resultado.sucesso(valor: valores.zip(datas).map { |valor, data| { valor: valor, data_vencimento: data } })
  end

  private

  def dividir_valor
    valor_por_parcela = (@valor_total / @numero_parcelas).floor(2)
    valores = Array.new(@numero_parcelas, valor_por_parcela)
    ajuste = @valor_total - (valor_por_parcela * @numero_parcelas)
    valores[-1] = (valores[-1] + ajuste).round(2)
    valores
  end

  def calcular_datas_de_vencimento
    mes_base = mes_da_primeira_fatura
    (0...@numero_parcelas).map { |indice| data_de_vencimento_do_mes(mes_base + indice.months) }
  end

  # Uma compra feita até o dia de fechamento cai na fatura do próprio mês;
  # depois do fechamento, cai na fatura do mês seguinte.
  def mes_da_primeira_fatura
    if @data_compra.day <= @dia_fechamento
      @data_compra.beginning_of_month
    else
      (@data_compra + 1.month).beginning_of_month
    end
  end

  def data_de_vencimento_do_mes(mes)
    dia = [ @dia_vencimento, mes.end_of_month.day ].min
    Date.new(mes.year, mes.month, dia)
  end
end
