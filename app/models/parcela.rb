class Parcela < ApplicationRecord
  belongs_to :origem, polymorphic: true

  enum :status, { pendente: 0, paga: 1 }

  STATUS_LABEL = { "pendente" => "Pendente", "paga" => "Paga" }.freeze

  validates :valor, presence: true, numericality: { greater_than: 0 }
  validates :data_vencimento, presence: true

  def atrasada?
    pendente? && data_vencimento < Date.current
  end

  def status_label
    return "Atrasada" if atrasada?

    STATUS_LABEL.fetch(status)
  end
end
