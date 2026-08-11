class Credor < ApplicationRecord
  has_many :cartoes, dependent: :restrict_with_error
  has_many :emprestimos, dependent: :restrict_with_error

  validates :nome, presence: true, uniqueness: true
end
