# Espelha SaldoRestanteQuery (que é pra Cartão) — soma das Parcelas do
# Empréstimo ainda pendentes ou atrasadas.
class SaldoRestanteEmprestimoQuery < ApplicationQuery
  def initialize(emprestimo:)
    @emprestimo = emprestimo
  end

  def call
    @emprestimo.parcelas.pendente.sum(:valor)
  end
end
