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
      vencimento = vencimento_do_saldo_herdado(saldo)

      LinhaCentralObrigacoes.new(
        origem: ObrigacoesQuery::ORIGEM_SALDO_HERDADO, descricao: saldo.cartao.nome, vencimento: vencimento,
        previsto: saldo.valor_total, pago: saldo.valor_pago, status: status_para(saldo.valor_pago.present?, vencimento)
      )
    end
  end

  def vencimento_do_saldo_herdado(saldo)
    dia = [ saldo.cartao.dia_vencimento, @mes.end_of_month.day ].min
    Date.new(@mes.year, @mes.month, dia)
  end

  def linhas_parcela
    Parcela.where(data_vencimento: @mes..@mes.end_of_month).includes(:origem).map do |parcela|
      LinhaCentralObrigacoes.new(
        origem: origem_da_parcela(parcela), descricao: descricao_da_parcela(parcela), vencimento: parcela.data_vencimento,
        previsto: parcela.valor, pago: parcela.paga? ? parcela.valor : nil,
        status: status_para(parcela.paga?, parcela.data_vencimento)
      )
    end
  end

  def origem_da_parcela(parcela)
    parcela.origem_emprestimo? ? ObrigacoesQuery::ORIGEM_PARCELA_EMPRESTIMO : ObrigacoesQuery::ORIGEM_PARCELA_COMPRA
  end

  def descricao_da_parcela(parcela)
    parcela.origem_emprestimo? ? parcela.origem.nome : "Cartão #{parcela.origem.cartao.nome}"
  end

  # Despesa é lançada como um fato já resolvido (ver ObrigacoesQuery) — não
  # tem estado de pagamento separado, então previsto e pago são o mesmo
  # valor, sem variação.
  def linhas_despesa_fixa
    Despesa.fixa.includes(:categoria).where(data: @mes..@mes.end_of_month).map do |despesa|
      LinhaCentralObrigacoes.new(
        origem: ObrigacoesQuery::ORIGEM_DESPESA_FIXA, descricao: despesa.categoria.nome, vencimento: despesa.data,
        previsto: despesa.valor, pago: despesa.valor, status: :paga
      )
    end
  end

  def status_para(pago, vencimento)
    return :paga if pago

    vencimento < Date.current ? :atrasada : :pendente
  end
end
