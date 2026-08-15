class CreateParcelamentos < ActiveRecord::Migration[7.2]
  def change
    create_table :parcelamentos do |t|
      t.references :categoria, null: false, foreign_key: true
      t.integer :tipo
      t.integer :forma_pagamento, null: false
      t.decimal :valor_total, precision: 10, scale: 2, null: false
      t.integer :numero_parcelas, null: false
      t.date :data, null: false

      t.timestamps
    end

    add_index :parcelamentos, :data
  end
end
