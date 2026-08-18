# Um dos dois espaços de dados independentes do app (ver CONTEXT.md e ADR
# 0007). Não tem senha própria — a troca entre Perfis é livre, protegida
# só pela autenticação HTTP Basic na frente do app inteiro.
class Perfil < ApplicationRecord
  validates :nome, presence: true, uniqueness: true
end
