class CreateTaxasCdi < ActiveRecord::Migration[7.2]
  def change
    create_table :taxas_cdi do |t|
      t.decimal :valor, precision: 6, scale: 3, null: false

      t.timestamps
    end
  end
end
