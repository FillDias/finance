class Aporte < ApplicationRecord
  include PertenceAPerfil

  belongs_to :investimento

  validates :valor, presence: true, numericality: { greater_than: 0 }
  validates :data, presence: true
end
