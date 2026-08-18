# Ver ADR 0007. Inclua em qualquer model que guarda dado pertencente a um
# Perfil específico — escopa toda consulta padrão (Model.where/find/all)
# pelo Current.perfil da request, e preenche perfil_id sozinho na criação.
# default_scope falha fechado: sem Current.perfil, não retorna nada, nunca
# retorna tudo. Auditar "quem pertence a um Perfil" vira um grep só: quem
# inclui este concern.
module PertenceAPerfil
  extend ActiveSupport::Concern

  included do
    belongs_to :perfil
    attribute :perfil_id, default: -> { Current.perfil&.id }
    default_scope { where(perfil_id: Current.perfil&.id || 0) }
  end
end
