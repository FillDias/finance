# Divide um valor total em N parcelas mensais, a partir de um mês-base já
# resolvido pelo chamador (GerarParcelas resolve o mês-base a partir do dia
# de fechamento do Cartão; CriarParcelamento usa o próprio mês da Despesa,
# sem corte nenhum).
class DividirParcelas < ApplicationService
  def initialize(valor_total:, numero_parcelas:, mes_base:, dia_vencimento:)
    @valor_total = valor_total.to_d
    @numero_parcelas = numero_parcelas.to_i
    @mes_base = mes_base
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
    (0...@numero_parcelas).map { |indice| data_de_vencimento_do_mes(@mes_base + indice.months) }
  end

  def data_de_vencimento_do_mes(mes)
    dia = [ @dia_vencimento, mes.end_of_month.day ].min
    Date.new(mes.year, mes.month, dia)
  end
end
