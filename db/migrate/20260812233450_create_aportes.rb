class CreateAportes < ActiveRecord::Migration[7.2]
  def change
    create_table :aportes do |t|
      t.references :investimento, null: false, foreign_key: true
      t.decimal :valor, precision: 10, scale: 2, null: false
      t.date :data, null: false

      t.timestamps
    end

    add_index :aportes, :data
  end
end
