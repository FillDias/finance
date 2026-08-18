# Roda depois de db/scripts/associar_perfil_aos_dados.rb ter associado
# todo registro existente a um Perfil — sem isso, essa constraint falha
# (mesmo padrão de ChangeCategoriaNullFalseOnEmprestimos).
class ChangePerfilNullFalseOnOwnedModels < ActiveRecord::Migration[8.1]
  TABELAS = %i[
    rendas despesas credores cartoes saldos_herdados fatura_pagamentos
    compras emprestimos parcelamentos parcelas investimentos aportes
  ].freeze

  def change
    TABELAS.each { |tabela| change_column_null tabela, :perfil_id, false }
  end
end
