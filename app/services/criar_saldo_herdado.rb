class CriarSaldoHerdado < ApplicationService
  def initialize(cartao_id:, mes_referencia:, valor_total:)
    @cartao_id = cartao_id
    @mes_referencia = mes_referencia
    @valor_total = valor_total
  end

  def call
    saldo = SaldoHerdado.new(cartao_id: @cartao_id, mes_referencia: @mes_referencia, valor_total: @valor_total)

    if saldo.save
      Resultado.sucesso(valor: saldo)
    else
      Resultado.erro(*saldo.errors.full_messages, valor: saldo)
    end
  end
end
