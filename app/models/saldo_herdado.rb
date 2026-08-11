class SaldoHerdado < ApplicationRecord
  belongs_to :cartao

  before_validation :normalizar_mes_referencia

  validates :mes_referencia, presence: true, uniqueness: { scope: :cartao_id }
  validates :valor_total, presence: true, numericality: { greater_than: 0 }
  validates :valor_pago, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :valor_pago_e_data_pagamento_juntos

  def quitado_antecipadamente?
    valor_pago.present?
  end

  private

  def normalizar_mes_referencia
    self.mes_referencia = mes_referencia.beginning_of_month if mes_referencia.present?
  end

  def valor_pago_e_data_pagamento_juntos
    return if valor_pago.present? == data_pagamento.present?

    errors.add(:base, "Valor pago e data de pagamento devem ser preenchidos juntos")
  end
end
