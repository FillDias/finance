class CreateTiposInvestimento < ActiveRecord::Migration[7.2]
  def change
    create_table :tipos_investimento do |t|
      t.string :nome, null: false

      t.timestamps
    end

    add_index :tipos_investimento, :nome, unique: true
  end
end
