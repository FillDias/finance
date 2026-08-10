class Categoria < ApplicationRecord
  has_many :despesas, dependent: :restrict_with_error

  validates :nome, presence: true, uniqueness: true
end
