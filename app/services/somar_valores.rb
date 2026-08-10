# Exemplo de referência para a convenção ApplicationService (ver ADR 0004) —
# não é uma feature de domínio. Services reais seguem o mesmo formato:
# .call(...) retornando um Resultado.
class SomarValores < ApplicationService
  def initialize(a, b)
    @a = a
    @b = b
  end

  def call
    return Resultado.erro("a e b devem ser numéricos") unless @a.is_a?(Numeric) && @b.is_a?(Numeric)

    Resultado.sucesso(valor: @a + @b)
  end
end
