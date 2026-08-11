class Emprestimo < ApplicationRecord
  # Só existe pra re-exibir o texto submetido no formulário se a criação
  # falhar (ver CriarEmprestimo) — não é persistido.
  attr_accessor :cronograma_texto

  belongs_to :credor
  has_many :parcelas, as: :origem, dependent: :destroy

  validates :nome, presence: true
  validates :valor_total, presence: true, numericality: { greater_than: 0 }
end
