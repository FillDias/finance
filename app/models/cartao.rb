class Cartao < ApplicationRecord
  belongs_to :credor
  has_many :saldos_herdados, dependent: :destroy

  validates :nome, presence: true
  validates :limite_total, presence: true, numericality: { greater_than: 0 }
  validates :dia_fechamento, presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 31 }
  validates :dia_vencimento, presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 31 }
  validates :data_corte, presence: true
end
