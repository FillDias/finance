# Compartilhado entre ObrigacoesQuery e CentralDeObrigacoesQuery — mesma
# regra pago/pendente/atrasada pros dois.
module StatusObrigacao
  def self.para(pago:, vencimento:)
    return :paga if pago

    vencimento < Date.current ? :atrasada : :pendente
  end
end
