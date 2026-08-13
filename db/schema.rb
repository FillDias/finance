# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2026_08_13_104454) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "aportes", force: :cascade do |t|
    t.bigint "investimento_id", null: false
    t.decimal "valor", precision: 10, scale: 2, null: false
    t.date "data", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data"], name: "index_aportes_on_data"
    t.index ["investimento_id"], name: "index_aportes_on_investimento_id"
  end

  create_table "cartoes", force: :cascade do |t|
    t.string "nome", null: false
    t.bigint "credor_id", null: false
    t.decimal "limite_total", precision: 10, scale: 2, null: false
    t.integer "dia_fechamento", null: false
    t.integer "dia_vencimento", null: false
    t.date "data_corte", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["credor_id"], name: "index_cartoes_on_credor_id"
  end

  create_table "categorias", force: :cascade do |t|
    t.string "nome", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nome"], name: "index_categorias_on_nome", unique: true
  end

  create_table "compras", force: :cascade do |t|
    t.bigint "cartao_id", null: false
    t.date "data_compra", null: false
    t.decimal "valor_total", precision: 10, scale: 2, null: false
    t.boolean "parcelado", default: false, null: false
    t.integer "numero_parcelas", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "categoria_id"
    t.integer "tipo"
    t.index ["cartao_id"], name: "index_compras_on_cartao_id"
    t.index ["categoria_id"], name: "index_compras_on_categoria_id"
    t.index ["data_compra"], name: "index_compras_on_data_compra"
  end

  create_table "credores", force: :cascade do |t|
    t.string "nome", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nome"], name: "index_credores_on_nome", unique: true
  end

  create_table "despesas", force: :cascade do |t|
    t.decimal "valor", precision: 10, scale: 2, null: false
    t.date "data", null: false
    t.bigint "categoria_id", null: false
    t.integer "tipo", null: false
    t.integer "forma_pagamento", null: false
    t.integer "dia_vencimento"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["categoria_id"], name: "index_despesas_on_categoria_id"
    t.index ["data"], name: "index_despesas_on_data"
  end

  create_table "emprestimos", force: :cascade do |t|
    t.string "nome", null: false
    t.bigint "credor_id", null: false
    t.decimal "valor_total", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["credor_id"], name: "index_emprestimos_on_credor_id"
  end

  create_table "fatura_pagamentos", force: :cascade do |t|
    t.bigint "cartao_id", null: false
    t.date "mes_referencia", null: false
    t.decimal "valor_pago", precision: 10, scale: 2, null: false
    t.date "data_pagamento", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cartao_id", "mes_referencia"], name: "index_fatura_pagamentos_on_cartao_id_and_mes_referencia", unique: true
    t.index ["cartao_id"], name: "index_fatura_pagamentos_on_cartao_id"
  end

  create_table "investimentos", force: :cascade do |t|
    t.bigint "tipo_investimento_id", null: false
    t.string "instituicao", null: false
    t.decimal "taxa_rendimento", precision: 6, scale: 3, null: false
    t.integer "periodicidade_taxa", default: 0, null: false
    t.date "data_vencimento"
    t.integer "status", default: 0, null: false
    t.decimal "valor_resgatado", precision: 10, scale: 2
    t.date "data_resgate"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tipo_investimento_id"], name: "index_investimentos_on_tipo_investimento_id"
  end

  create_table "parcelas", force: :cascade do |t|
    t.string "origem_type", null: false
    t.bigint "origem_id", null: false
    t.decimal "valor", precision: 10, scale: 2, null: false
    t.date "data_vencimento", null: false
    t.integer "status", default: 0, null: false
    t.date "data_pagamento"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data_vencimento"], name: "index_parcelas_on_data_vencimento"
    t.index ["origem_type", "origem_id"], name: "index_parcelas_on_origem"
  end

  create_table "rendas", force: :cascade do |t|
    t.decimal "valor", precision: 10, scale: 2, null: false
    t.date "data", null: false
    t.string "fonte", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["data"], name: "index_rendas_on_data"
  end

  create_table "saldos_herdados", force: :cascade do |t|
    t.bigint "cartao_id", null: false
    t.date "mes_referencia", null: false
    t.decimal "valor_total", precision: 10, scale: 2, null: false
    t.decimal "valor_pago", precision: 10, scale: 2
    t.date "data_pagamento"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cartao_id", "mes_referencia"], name: "index_saldos_herdados_on_cartao_id_and_mes_referencia", unique: true
    t.index ["cartao_id"], name: "index_saldos_herdados_on_cartao_id"
  end

  create_table "taxas_cdi", force: :cascade do |t|
    t.decimal "valor", precision: 6, scale: 3, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tipos_investimento", force: :cascade do |t|
    t.string "nome", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nome"], name: "index_tipos_investimento_on_nome", unique: true
  end

  add_foreign_key "aportes", "investimentos"
  add_foreign_key "cartoes", "credores"
  add_foreign_key "compras", "cartoes"
  add_foreign_key "compras", "categorias"
  add_foreign_key "despesas", "categorias"
  add_foreign_key "emprestimos", "credores"
  add_foreign_key "fatura_pagamentos", "cartoes"
  add_foreign_key "investimentos", "tipos_investimento"
  add_foreign_key "saldos_herdados", "cartoes"
end
