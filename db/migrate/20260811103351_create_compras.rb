class CreateCompras < ActiveRecord::Migration[7.2]
  def change
    create_table :compras do |t|
      t.references :cartao, null: false, foreign_key: true
      t.date :data_compra, null: false
      t.decimal :valor_total, precision: 10, scale: 2, null: false
      t.boolean :parcelado, null: false, default: false
      t.integer :numero_parcelas, null: false, default: 1

      t.timestamps
    end

    add_index :compras, :data_compra
  end
end
