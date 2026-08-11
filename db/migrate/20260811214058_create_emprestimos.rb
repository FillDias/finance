class CreateEmprestimos < ActiveRecord::Migration[7.2]
  def change
    create_table :emprestimos do |t|
      t.string :nome, null: false
      t.references :credor, null: false, foreign_key: true
      t.decimal :valor_total, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end
