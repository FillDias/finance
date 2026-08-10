class CreateRendas < ActiveRecord::Migration[7.2]
  def change
    create_table :rendas do |t|
      t.decimal :valor, precision: 10, scale: 2, null: false
      t.date :data, null: false
      t.string :fonte, null: false

      t.timestamps
    end

    add_index :rendas, :data
  end
end
