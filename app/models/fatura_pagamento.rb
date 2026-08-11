class FaturaPagamento < ApplicationRecord
  belongs_to :cartao

  before_validation :normalizar_mes_referencia

  validates :mes_referencia, presence: true, uniqueness: { scope: :cartao_id }
  validates :valor_pago, presence: true, numericality: { greater_than: 0 }
  validates :data_pagamento, presence: true

  private

  def normalizar_mes_referencia
    self.mes_referencia = mes_referencia.beginning_of_month if mes_referencia.present?
  end
end
