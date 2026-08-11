class CreateCredores < ActiveRecord::Migration[7.2]
  def change
    create_table :credores do |t|
      t.string :nome, null: false

      t.timestamps
    end

    add_index :credores, :nome, unique: true
  end
end
