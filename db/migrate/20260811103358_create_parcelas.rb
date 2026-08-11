class CreateParcelas < ActiveRecord::Migration[7.2]
  def change
    create_table :parcelas do |t|
      t.references :origem, polymorphic: true, null: false
      t.decimal :valor, precision: 10, scale: 2, null: false
      t.date :data_vencimento, null: false
      t.integer :status, null: false, default: 0
      t.date :data_pagamento

      t.timestamps
    end

    add_index :parcelas, :data_vencimento
  end
end
