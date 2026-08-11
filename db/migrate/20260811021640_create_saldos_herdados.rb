class CreateSaldosHerdados < ActiveRecord::Migration[7.2]
  def change
    create_table :saldos_herdados do |t|
      t.references :cartao, null: false, foreign_key: true
      t.date :mes_referencia, null: false
      t.decimal :valor_total, precision: 10, scale: 2, null: false
      t.decimal :valor_pago, precision: 10, scale: 2
      t.date :data_pagamento

      t.timestamps
    end

    add_index :saldos_herdados, [ :cartao_id, :mes_referencia ], unique: true
  end
end
