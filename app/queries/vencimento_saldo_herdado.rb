# Saldo Herdado não tem uma data de vencimento própria — usa o dia de
# vencimento do Cartão aplicado ao mês de referência, com o mesmo clamping
# de fim de mês que GerarParcelas usa para Parcela. Compartilhado entre
# ObrigacoesQuery e CentralDeObrigacoesQuery, que precisam do mesmo cálculo.
module VencimentoSaldoHerdado
  def self.para(saldo)
    mes = saldo.mes_referencia
    dia = [ saldo.cartao.dia_vencimento, mes.end_of_month.day ].min
    Date.new(mes.year, mes.month, dia)
  end
end
