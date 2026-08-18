# Credor é pessoal por Perfil (ver ADR 0007) — "Nubank" precisa poder
# existir uma vez por Perfil, não uma vez pra aplicação inteira.
class ScopeCredorNomeUniquenessToPerfil < ActiveRecord::Migration[8.1]
  def change
    remove_index :credores, :nome, unique: true
    add_index :credores, [ :perfil_id, :nome ], unique: true
  end
end
