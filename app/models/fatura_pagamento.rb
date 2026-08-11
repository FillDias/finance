class FaturaPagamento < ApplicationRecord
  include NormalizaMesReferencia

  belongs_to :cartao

  validates :mes_referencia, presence: true, uniqueness: { scope: :cartao_id }
  validates :valor_pago, presence: true, numericality: { greater_than: 0 }
  validates :data_pagamento, presence: true
end
