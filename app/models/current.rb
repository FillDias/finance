# Perfil atual da request, resolvido uma vez em ApplicationController#exigir_perfil
# a partir de session[:perfil_id] (ver ADR 0007). Os models donos de dado leem
# daqui pra escopar (default_scope) e pra preencher perfil_id na criação.
class Current < ActiveSupport::CurrentAttributes
  attribute :perfil
end
