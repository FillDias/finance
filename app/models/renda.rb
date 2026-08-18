class Renda < ApplicationRecord
  include PertenceAPerfil

  validates :valor, presence: true, numericality: { greater_than: 0 }
  validates :data, presence: true
  validates :fonte, presence: true
end
