class CreateDespesas < ActiveRecord::Migration[7.2]
  def change
    create_table :despesas do |t|
      t.decimal :valor, precision: 10, scale: 2, null: false
      t.date :data, null: false
      t.references :categoria, null: false, foreign_key: true
      t.integer :tipo, null: false
      t.integer :forma_pagamento, null: false
      t.integer :dia_vencimento

      t.timestamps
    end

    add_index :despesas, :data
  end
end
