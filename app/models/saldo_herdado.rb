class SaldoHerdado < ApplicationRecord
  include NormalizaMesReferencia
  include ValidarParPreenchido

  belongs_to :cartao

  validates :mes_referencia, presence: true, uniqueness: { scope: :cartao_id }
  validates :valor_total, presence: true, numericality: { greater_than: 0 }
  validates :valor_pago, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validar_par_preenchido :valor_pago, :data_pagamento

  def quitado_antecipadamente?
    valor_pago.present?
  end
end
