# Só soma o que compõe a dívida no próprio Cartão (Saldo Herdado em aberto +
# parcelas pendentes das Compras feitas nele) — não inclui Despesa Fixa nem
# parcela de Empréstimo, que não pertencem a nenhum Cartão.
class DividaPorCartaoQuery < ApplicationQuery
  def call
    Cartao.order(:nome).filter_map do |cartao|
      saldo_herdado = cartao.saldos_herdados.where(valor_pago: nil).sum(:valor_total)
      parcelas = cartao.parcelas.pendente.sum(:valor)
      valor = saldo_herdado + parcelas
      { cartao_id: cartao.id, cartao: cartao.nome, valor: valor, saldo_herdado: saldo_herdado, parcelas: parcelas } if valor.positive?
    end
  end
end
