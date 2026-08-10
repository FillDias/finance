class CreateCategorias < ActiveRecord::Migration[7.2]
  def change
    create_table :categorias do |t|
      t.string :nome, null: false

      t.timestamps
    end

    add_index :categorias, :nome, unique: true
  end
end
