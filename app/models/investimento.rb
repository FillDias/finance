class Investimento < ApplicationRecord
  belongs_to :tipo_investimento

  enum :periodicidade_taxa, { mensal: 0, anual: 1 }
  enum :status, { ativo: 0, resgatado: 1 }

  PERIODICIDADE_LABEL = { "mensal" => "% ao mês", "anual" => "% ao ano" }.freeze
  STATUS_LABEL = { "ativo" => "Ativo", "resgatado" => "Resgatado" }.freeze

  validates :instituicao, presence: true
  validates :taxa_rendimento, presence: true, numericality: { greater_than: 0 }
  validates :periodicidade_taxa, presence: true
  validates :status, presence: true
  validates :valor_resgatado, numericality: { greater_than: 0 }, allow_nil: true
  validate :valor_resgatado_e_data_resgate_juntos

  def periodicidade_taxa_label
    PERIODICIDADE_LABEL.fetch(periodicidade_taxa)
  end

  def status_label
    STATUS_LABEL.fetch(status)
  end

  private

  def valor_resgatado_e_data_resgate_juntos
    return if valor_resgatado.present? == data_resgate.present?

    errors.add(:base, "Valor resgatado e data de resgate devem ser preenchidos juntos")
  end
end
