class ObrigacoesQuery < ApplicationQuery
  ORIGEM_SALDO_HERDADO = "Saldo Herdado"
  ORIGEM_PARCELA_COMPRA = "Parcela de Compra"
  ORIGEM_PARCELA_EMPRESTIMO = "Parcela de Empréstimo"
  ORIGEM_DESPESA_FIXA = "Despesa Fixa"

  def initialize(data_inicio: nil, data_fim: nil)
    @data_inicio = data_inicio.presence
    @data_fim = data_fim.presence
  end

  def call
    itens = saldo_herdado_obrigacoes + parcela_obrigacoes + despesa_fixa_obrigacoes
    itens.select { |item| dentro_do_periodo?(item.vencimento) }.sort_by(&:vencimento)
  end

  private

  # Saldo Herdado não tem uma data de vencimento própria — usa o dia de
  # vencimento do Cartão aplicado ao mês de referência, com o mesmo
  # clamping de fim de mês que GerarParcelas usa para Parcela.
  def saldo_herdado_obrigacoes
    SaldoHerdado.where(valor_pago: nil).includes(:cartao).map do |saldo|
      vencimento = vencimento_do_saldo_herdado(saldo)

      Obrigacao.new(
        valor: saldo.valor_total, vencimento: vencimento, status: status_calculado(pago: false, vencimento: vencimento),
        origem: ORIGEM_SALDO_HERDADO, registro: saldo
      )
    end
  end

  def vencimento_do_saldo_herdado(saldo)
    mes = saldo.mes_referencia
    dia = [ saldo.cartao.dia_vencimento, mes.end_of_month.day ].min
    Date.new(mes.year, mes.month, dia)
  end

  def parcela_obrigacoes
    Parcela.pendente.includes(:origem).map do |parcela|
      Obrigacao.new(
        valor: parcela.valor, vencimento: parcela.data_vencimento,
        status: status_calculado(pago: false, vencimento: parcela.data_vencimento),
        origem: origem_da_parcela(parcela), registro: parcela
      )
    end
  end

  def origem_da_parcela(parcela)
    parcela.origem_emprestimo? ? ORIGEM_PARCELA_EMPRESTIMO : ORIGEM_PARCELA_COMPRA
  end

  # Despesa não tem estado de pagamento (é lançada como um fato já
  # resolvido, ao contrário de Saldo Herdado/Parcela) — ver CONTEXT.md.
  # `data` é tratada como o vencimento; o status nunca é "paga".
  def despesa_fixa_obrigacoes
    Despesa.fixa.map do |despesa|
      Obrigacao.new(
        valor: despesa.valor, vencimento: despesa.data,
        status: despesa.data < Date.current ? :atrasada : :pendente,
        origem: ORIGEM_DESPESA_FIXA, registro: despesa
      )
    end
  end

  def status_calculado(pago:, vencimento:)
    return :paga if pago

    vencimento < Date.current ? :atrasada : :pendente
  end

  def dentro_do_periodo?(vencimento)
    return true if @data_inicio.blank? && @data_fim.blank?

    inicio = @data_inicio.presence&.to_date || Date.new(1, 1, 1)
    fim = @data_fim.presence&.to_date || Date.new(9999, 12, 31)
    vencimento.between?(inicio, fim)
  end
end
