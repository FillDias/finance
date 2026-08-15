# Equivalente a CriarCompraNoCartao, mas pra Despesa parcelada fora do
# Cartão (ver CONTEXT.md) — mesmo formato de retorno, mesma ideia de gerar
# as Parcelas de uma vez no lançamento, só sem corte de fatura envolvido.
class CriarParcelamento < ApplicationService
  def initialize(valor_total:, numero_parcelas:, data:, categoria_id:, tipo:, forma_pagamento:)
    @valor_total = valor_total
    @numero_parcelas = numero_parcelas
    @data = data
    @categoria_id = categoria_id
    @tipo = tipo
    @forma_pagamento = forma_pagamento
  end

  def call
    parcelamento = Parcelamento.new(
      valor_total: @valor_total, numero_parcelas: @numero_parcelas, data: @data,
      categoria_id: @categoria_id, tipo: @tipo, forma_pagamento: @forma_pagamento
    )
    return Resultado.erro(*parcelamento.errors.full_messages, valor: parcelamento) unless parcelamento.valid?

    parcelas_calculadas = DividirParcelas.call(
      valor_total: parcelamento.valor_total, numero_parcelas: parcelamento.numero_parcelas,
      mes_base: parcelamento.data.beginning_of_month, dia_vencimento: parcelamento.data.day
    )

    ActiveRecord::Base.transaction do
      parcelamento.save!
      parcelas_calculadas.valor.each do |dados|
        parcelamento.parcelas.create!(valor: dados[:valor], data_vencimento: dados[:data_vencimento], status: :pendente)
      end
    end

    Resultado.sucesso(valor: parcelamento)
  end
end
