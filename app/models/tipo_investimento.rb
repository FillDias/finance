class TipoInvestimento < ApplicationRecord
  has_many :investimentos, dependent: :restrict_with_error

  validates :nome, presence: true, uniqueness: true
end
