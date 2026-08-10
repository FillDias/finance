# Exemplo de referência para a convenção ApplicationQuery (ver ADR 0004) —
# não é uma feature de domínio. Queries reais seguem o mesmo formato:
# .call(...) retornando dados prontos, nunca um ActiveRecord::Relation.
class TotalDeValores < ApplicationQuery
  def initialize(valores)
    @valores = valores
  end

  def call
    @valores.sum
  end
end
