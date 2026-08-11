class CreateCartoes < ActiveRecord::Migration[7.2]
  def change
    create_table :cartoes do |t|
      t.string :nome, null: false
      t.references :credor, null: false, foreign_key: true
      t.decimal :limite_total, precision: 10, scale: 2, null: false
      t.integer :dia_fechamento, null: false
      t.integer :dia_vencimento, null: false
      t.date :data_corte, null: false

      t.timestamps
    end
  end
end
