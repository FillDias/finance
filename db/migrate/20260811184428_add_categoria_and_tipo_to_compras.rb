class AddCategoriaAndTipoToCompras < ActiveRecord::Migration[7.2]
  def change
    add_reference :compras, :categoria, null: true, foreign_key: true
    add_column :compras, :tipo, :integer
  end
end
