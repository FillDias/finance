class CreateInvestimentos < ActiveRecord::Migration[7.2]
  def change
    create_table :investimentos do |t|
      t.references :tipo_investimento, null: false, foreign_key: true
      t.string :instituicao, null: false
      t.decimal :taxa_rendimento, precision: 6, scale: 3, null: false
      t.integer :periodicidade_taxa, null: false, default: 0
      t.date :data_vencimento
      t.integer :status, null: false, default: 0
      t.decimal :valor_resgatado, precision: 10, scale: 2
      t.date :data_resgate

      t.timestamps
    end
  end
end
