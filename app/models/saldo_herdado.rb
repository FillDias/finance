class SaldoHerdado < ApplicationRecord
  include NormalizaMesReferencia

  belongs_to :cartao

  validates :mes_referencia, presence: true, uniqueness: { scope: :cartao_id }
  validates :valor_total, presence: true, numericality: { greater_than: 0 }
  validates :valor_pago, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :valor_pago_e_data_pagamento_juntos

  def quitado_antecipadamente?
    valor_pago.present?
  end

  private

  def valor_pago_e_data_pagamento_juntos
    return if valor_pago.present? == data_pagamento.present?

    errors.add(:base, "Valor pago e data de pagamento devem ser preenchidos juntos")
  end
end
