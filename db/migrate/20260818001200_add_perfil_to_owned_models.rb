# Nullable de propósito — todo dado existente hoje é do perfil "Fill" e
# precisa ser associado via db/scripts/associar_perfil_aos_dados.rb antes
# da migration seguinte (que torna a coluna obrigatória). Ver ADR 0007
# pra por que esses 12 models levam perfil_id direto, em vez de só os
# "donos" de topo.
class AddPerfilToOwnedModels < ActiveRecord::Migration[8.1]
  TABELAS = %i[
    rendas despesas credores cartoes saldos_herdados fatura_pagamentos
    compras emprestimos parcelamentos parcelas investimentos aportes
  ].freeze

  def change
    TABELAS.each do |tabela|
      # to_table explícito: o pluralizador do Rails não sabe que "perfil"
      # vira "perfis" em português — sem isso, tentaria referenciar uma
      # tabela "perfils" inexistente.
      add_reference tabela, :perfil, null: true, foreign_key: { to_table: :perfis }
    end
  end
end
