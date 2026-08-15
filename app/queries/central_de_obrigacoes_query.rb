# Diferente de ObrigacoesQuery (que nunca devolve item pago, pra listar só o
# que falta pagar), aqui o objetivo é a tabela estilo P&L do mês, que
# precisa comparar Previsto x Pago — então itens já pagos entram também.
class CentralDeObrigacoesQuery < ApplicationQuery
  def initialize(mes: Date.current)
    @mes = mes.to_date.beginning_of_month
  end

  def call
    (linhas_saldo_herdado + linhas_parcela + linhas_despesa_fixa).sort_by(&:vencimento)
  end

  private

  def linhas_saldo_herdado
    SaldoHerdado.includes(:cartao).where(mes_referencia: @mes).map do |saldo|
      vencimento = VencimentoSaldoHerdado.para(saldo)

      LinhaCentralObrigacoes.new(
        origem: Obrigacao::ORIGEM_SALDO_HERDADO, descricao: saldo.cartao.nome, vencimento: vencimento,
        previsto: saldo.valor_total, pago: saldo.valor_pago, status: StatusObrigacao.para(pago: saldo.valor_pago.present?, vencimento: vencimento)
      )
    end
  end

  def linhas_parcela
    Parcela.where(data_vencimento: @mes..@mes.end_of_month).includes(:origem).map do |parcela|
      LinhaCentralObrigacoes.new(
        origem: origem_da_parcela(parcela), descricao: descricao_da_parcela(parcela), vencimento: parcela.data_vencimento,
        previsto: parcela.valor, pago: parcela.paga? ? parcela.valor : nil,
        status: StatusObrigacao.para(pago: parcela.paga?, vencimento: parcela.data_vencimento)
      )
    end
  end

  def origem_da_parcela(parcela)
    return Obrigacao::ORIGEM_PARCELA_EMPRESTIMO if parcela.origem_emprestimo?
    return Obrigacao::ORIGEM_PARCELAMENTO if parcela.origem_parcelamento?

    Obrigacao::ORIGEM_PARCELA_COMPRA
  end

  def descricao_da_parcela(parcela)
    return parcela.origem.nome if parcela.origem_emprestimo?
    return parcela.origem.categoria.nome if parcela.origem_parcelamento?

    "Cartão #{parcela.origem.cartao.nome}"
  end

  # Despesa é lançada como um fato já resolvido (ver ObrigacoesQuery) — não
  # tem estado de pagamento separado, então previsto e pago são o mesmo
  # valor, sem variação.
  def linhas_despesa_fixa
    Despesa.fixa.includes(:categoria).where(data: @mes..@mes.end_of_month).map do |despesa|
      LinhaCentralObrigacoes.new(
        origem: Obrigacao::ORIGEM_DESPESA_FIXA, descricao: despesa.categoria.nome, vencimento: despesa.data,
        previsto: despesa.valor, pago: despesa.valor, status: :paga
      )
    end
  end
end
