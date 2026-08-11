class UtilizacaoLimiteQuery < ApplicationQuery
  def initialize(cartao:)
    @cartao = cartao
  end

  def call
    return 0.to_d if @cartao.limite_total.zero?

    SaldoRestanteQuery.call(cartao: @cartao) / @cartao.limite_total
  end
end
