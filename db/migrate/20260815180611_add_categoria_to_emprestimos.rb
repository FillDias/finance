# Nullable de propósito — o único Emprestimo real hoje (Financiamento Etios
# BV) precisa ser categorizado manualmente antes da constraint NOT NULL
# entrar (ver migration seguinte e db/scripts/categorizar_emprestimos.rb).
class AddCategoriaToEmprestimos < ActiveRecord::Migration[7.2]
  def change
    add_reference :emprestimos, :categoria, null: true, foreign_key: true
  end
end
