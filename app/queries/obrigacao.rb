class Obrigacao < Struct.new(:valor, :vencimento, :status, :origem, :registro, keyword_init: true)
  ORIGEM_SALDO_HERDADO = "Saldo Herdado"
  ORIGEM_PARCELA_COMPRA = "Parcela de Compra"
  ORIGEM_PARCELA_EMPRESTIMO = "Parcela de Empréstimo"
  ORIGEM_PARCELAMENTO = "Parcela de Parcelamento"
  ORIGEM_DESPESA_FIXA = "Despesa Fixa"

  def pendente?
    status == :pendente
  end

  def paga?
    status == :paga
  end

  def atrasada?
    status == :atrasada
  end
end
