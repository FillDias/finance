# Soma Despesa + Compra-com-categoria (Despesa paga no cartão, ver ticket
# #9) — mesma regra de "mesma linha, nunca duas" que DespesasFiltradas usa
# pra listar, só que aqui somando em vez de listar.
class SaidasDoMesQuery < ApplicationQuery
  def initialize(mes: Date.current)
    @mes = mes.to_date.beginning_of_month
  end

  def call
    despesas + compras_categorizadas
  end

  private

  def despesas
    Despesa.where(data: @mes..@mes.end_of_month).sum(:valor)
  end

  def compras_categorizadas
    Compra.where(data_compra: @mes..@mes.end_of_month).where.not(categoria_id: nil).sum(:valor_total)
  end
end
