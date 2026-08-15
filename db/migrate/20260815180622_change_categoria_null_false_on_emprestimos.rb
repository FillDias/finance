# Roda depois de db/scripts/categorizar_emprestimos.rb ter categorizado
# todo Emprestimo existente — sem isso, essa constraint falha.
class ChangeCategoriaNullFalseOnEmprestimos < ActiveRecord::Migration[7.2]
  def change
    change_column_null :emprestimos, :categoria_id, false
  end
end
