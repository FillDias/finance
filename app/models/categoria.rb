class Categoria < ApplicationRecord
  # Compra e Parcelamento já tinham essa FK sem o has_many correspondente —
  # excluir uma Categoria referenciada por qualquer um dos três batia direto
  # na constraint do banco (ActiveRecord::InvalidForeignKey não tratada) em
  # vez de dar o erro de validação amigável que Despesa já tinha.
  has_many :despesas, dependent: :restrict_with_error
  has_many :compras, dependent: :restrict_with_error
  has_many :parcelamentos, dependent: :restrict_with_error
  has_many :emprestimos, dependent: :restrict_with_error

  validates :nome, presence: true, uniqueness: true
end
