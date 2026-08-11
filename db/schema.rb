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

ActiveRecord::Schema[7.2].define(version: 2026_08_11_021640) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

  add_foreign_key "cartoes", "credores"
  add_foreign_key "despesas", "categorias"
  add_foreign_key "saldos_herdados", "cartoes"
end
