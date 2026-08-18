class Compra < ApplicationRecord
  include ClassificacaoFixaVariavel
  include PertenceAPerfil

  belongs_to :cartao
  belongs_to :categoria, optional: true
  has_many :parcelas, as: :origem, dependent: :destroy

  validates :data_compra, presence: true
  validates :valor_total, presence: true, numericality: { greater_than: 0 }
  validates :numero_parcelas, presence: true, numericality: { only_integer: true, equal_to: 1 }, unless: :parcelado
  validates :numero_parcelas, numericality: { only_integer: true, greater_than_or_equal_to: 2 }, if: :parcelado
end
