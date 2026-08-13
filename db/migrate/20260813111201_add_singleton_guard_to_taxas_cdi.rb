class AddSingletonGuardToTaxasCdi < ActiveRecord::Migration[7.2]
  def change
    # TaxaCdi.atual's first_or_create! isn't atomic — two concurrent
    # first-time requests could both find no row and both insert. The
    # model-level uniqueness validation only guards sequential misuse.
    # A unique index on a constant expression makes Postgres itself
    # reject any second row, closing the race at the only layer that
    # actually can.
    add_index :taxas_cdi, "(true)", unique: true, name: "index_taxas_cdi_on_singleton"
  end
end
