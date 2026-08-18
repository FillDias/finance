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

ActiveRecord::Schema[8.1].define(version: 2026_08_18_001500) do
  create_schema "extensions"

  # These are extensions that must be enabled in order to support this database
  enable_extension "extensions.pg_stat_statements"
  enable_extension "extensions.pgcrypto"
  enable_extension "extensions.uuid-ossp"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "vault.supabase_vault"

  create_table "public.aportes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "data", null: false
    t.bigint "investimento_id", null: false
    t.bigint "perfil_id", null: false
    t.datetime "updated_at", null: false
    t.decimal "valor", precision: 10, scale: 2, null: false
    t.index ["data"], name: "index_aportes_on_data"
    t.index ["investimento_id"], name: "index_aportes_on_investimento_id"
    t.index ["perfil_id"], name: "index_aportes_on_perfil_id"
  end

  create_table "public.cartoes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "credor_id", null: false
    t.date "data_corte", null: false
    t.integer "dia_fechamento", null: false
    t.integer "dia_vencimento", null: false
    t.decimal "limite_total", precision: 10, scale: 2, null: false
    t.string "nome", null: false
    t.bigint "perfil_id", null: false
    t.datetime "updated_at", null: false
    t.index ["credor_id"], name: "index_cartoes_on_credor_id"
    t.index ["perfil_id"], name: "index_cartoes_on_perfil_id"
  end

  create_table "public.categorias", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "nome", null: false
    t.datetime "updated_at", null: false
    t.index ["nome"], name: "index_categorias_on_nome", unique: true
  end

  create_table "public.compras", force: :cascade do |t|
    t.bigint "cartao_id", null: false
    t.bigint "categoria_id"
    t.datetime "created_at", null: false
    t.date "data_compra", null: false
    t.integer "numero_parcelas", default: 1, null: false
    t.boolean "parcelado", default: false, null: false
    t.bigint "perfil_id", null: false
    t.integer "tipo"
    t.datetime "updated_at", null: false
    t.decimal "valor_total", precision: 10, scale: 2, null: false
    t.index ["cartao_id"], name: "index_compras_on_cartao_id"
    t.index ["categoria_id"], name: "index_compras_on_categoria_id"
    t.index ["data_compra"], name: "index_compras_on_data_compra"
    t.index ["perfil_id"], name: "index_compras_on_perfil_id"
  end

  create_table "public.credores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "nome", null: false
    t.bigint "perfil_id", null: false
    t.datetime "updated_at", null: false
    t.index ["perfil_id", "nome"], name: "index_credores_on_perfil_id_and_nome", unique: true
    t.index ["perfil_id"], name: "index_credores_on_perfil_id"
  end

  create_table "public.despesas", force: :cascade do |t|
    t.bigint "categoria_id", null: false
    t.datetime "created_at", null: false
    t.date "data", null: false
    t.integer "dia_vencimento"
    t.integer "forma_pagamento", null: false
    t.bigint "perfil_id", null: false
    t.integer "tipo", null: false
    t.datetime "updated_at", null: false
    t.decimal "valor", precision: 10, scale: 2, null: false
    t.index ["categoria_id"], name: "index_despesas_on_categoria_id"
    t.index ["data"], name: "index_despesas_on_data"
    t.index ["perfil_id"], name: "index_despesas_on_perfil_id"
  end

  create_table "public.emprestimos", force: :cascade do |t|
    t.bigint "categoria_id", null: false
    t.datetime "created_at", null: false
    t.bigint "credor_id", null: false
    t.string "nome", null: false
    t.bigint "perfil_id", null: false
    t.datetime "updated_at", null: false
    t.decimal "valor_total", precision: 10, scale: 2, null: false
    t.index ["categoria_id"], name: "index_emprestimos_on_categoria_id"
    t.index ["credor_id"], name: "index_emprestimos_on_credor_id"
    t.index ["perfil_id"], name: "index_emprestimos_on_perfil_id"
  end

  create_table "public.fatura_pagamentos", force: :cascade do |t|
    t.bigint "cartao_id", null: false
    t.datetime "created_at", null: false
    t.date "data_pagamento", null: false
    t.date "mes_referencia", null: false
    t.bigint "perfil_id", null: false
    t.datetime "updated_at", null: false
    t.decimal "valor_pago", precision: 10, scale: 2, null: false
    t.index ["cartao_id", "mes_referencia"], name: "index_fatura_pagamentos_on_cartao_id_and_mes_referencia", unique: true
    t.index ["cartao_id"], name: "index_fatura_pagamentos_on_cartao_id"
    t.index ["perfil_id"], name: "index_fatura_pagamentos_on_perfil_id"
  end

  create_table "public.investimentos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "data_resgate"
    t.date "data_vencimento"
    t.string "instituicao", null: false
    t.bigint "perfil_id", null: false
    t.integer "periodicidade_taxa", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.decimal "taxa_rendimento", precision: 6, scale: 3, null: false
    t.bigint "tipo_investimento_id", null: false
    t.datetime "updated_at", null: false
    t.decimal "valor_resgatado", precision: 10, scale: 2
    t.index ["perfil_id"], name: "index_investimentos_on_perfil_id"
    t.index ["tipo_investimento_id"], name: "index_investimentos_on_tipo_investimento_id"
  end

  create_table "public.parcelamentos", force: :cascade do |t|
    t.bigint "categoria_id", null: false
    t.datetime "created_at", null: false
    t.date "data", null: false
    t.integer "forma_pagamento", null: false
    t.integer "numero_parcelas", null: false
    t.bigint "perfil_id", null: false
    t.integer "tipo"
    t.datetime "updated_at", null: false
    t.decimal "valor_total", precision: 10, scale: 2, null: false
    t.index ["categoria_id"], name: "index_parcelamentos_on_categoria_id"
    t.index ["data"], name: "index_parcelamentos_on_data"
    t.index ["perfil_id"], name: "index_parcelamentos_on_perfil_id"
  end

  create_table "public.parcelas", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "data_pagamento"
    t.date "data_vencimento", null: false
    t.bigint "origem_id", null: false
    t.string "origem_type", null: false
    t.bigint "perfil_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.decimal "valor", precision: 10, scale: 2, null: false
    t.index ["data_vencimento"], name: "index_parcelas_on_data_vencimento"
    t.index ["origem_type", "origem_id"], name: "index_parcelas_on_origem"
    t.index ["perfil_id"], name: "index_parcelas_on_perfil_id"
  end

  create_table "public.perfis", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "nome", null: false
    t.datetime "updated_at", null: false
    t.index ["nome"], name: "index_perfis_on_nome", unique: true
  end

  create_table "public.rendas", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "data", null: false
    t.string "fonte", null: false
    t.bigint "perfil_id", null: false
    t.datetime "updated_at", null: false
    t.decimal "valor", precision: 10, scale: 2, null: false
    t.index ["data"], name: "index_rendas_on_data"
    t.index ["perfil_id"], name: "index_rendas_on_perfil_id"
  end

  create_table "public.saldos_herdados", force: :cascade do |t|
    t.bigint "cartao_id", null: false
    t.datetime "created_at", null: false
    t.date "data_pagamento"
    t.date "mes_referencia", null: false
    t.bigint "perfil_id", null: false
    t.datetime "updated_at", null: false
    t.decimal "valor_pago", precision: 10, scale: 2
    t.decimal "valor_total", precision: 10, scale: 2, null: false
    t.index ["cartao_id", "mes_referencia"], name: "index_saldos_herdados_on_cartao_id_and_mes_referencia", unique: true
    t.index ["cartao_id"], name: "index_saldos_herdados_on_cartao_id"
    t.index ["perfil_id"], name: "index_saldos_herdados_on_perfil_id"
  end

  create_table "public.taxas_cdi", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "valor", precision: 6, scale: 3, null: false
    t.index "(true)", name: "index_taxas_cdi_on_singleton", unique: true
  end

  create_table "public.tipos_investimento", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "nome", null: false
    t.datetime "updated_at", null: false
    t.index ["nome"], name: "index_tipos_investimento_on_nome", unique: true
  end

  add_foreign_key "public.aportes", "public.investimentos"
  add_foreign_key "public.aportes", "public.perfis"
  add_foreign_key "public.cartoes", "public.credores"
  add_foreign_key "public.cartoes", "public.perfis"
  add_foreign_key "public.compras", "public.cartoes"
  add_foreign_key "public.compras", "public.categorias"
  add_foreign_key "public.compras", "public.perfis"
  add_foreign_key "public.credores", "public.perfis"
  add_foreign_key "public.despesas", "public.categorias"
  add_foreign_key "public.despesas", "public.perfis"
  add_foreign_key "public.emprestimos", "public.categorias"
  add_foreign_key "public.emprestimos", "public.credores"
  add_foreign_key "public.emprestimos", "public.perfis"
  add_foreign_key "public.fatura_pagamentos", "public.cartoes"
  add_foreign_key "public.fatura_pagamentos", "public.perfis"
  add_foreign_key "public.investimentos", "public.perfis"
  add_foreign_key "public.investimentos", "public.tipos_investimento"
  add_foreign_key "public.parcelamentos", "public.categorias"
  add_foreign_key "public.parcelamentos", "public.perfis"
  add_foreign_key "public.parcelas", "public.perfis"
  add_foreign_key "public.rendas", "public.perfis"
  add_foreign_key "public.saldos_herdados", "public.cartoes"
  add_foreign_key "public.saldos_herdados", "public.perfis"

end
