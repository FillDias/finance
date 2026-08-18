class Investimento < ApplicationRecord
  include ValidarParPreenchido
  include PertenceAPerfil

  belongs_to :tipo_investimento
  has_many :aportes, dependent: :destroy

  enum :periodicidade_taxa, { mensal: 0, anual: 1 }
  enum :status, { ativo: 0, resgatado: 1 }

  PERIODICIDADE_LABEL = { "mensal" => "% ao mês", "anual" => "% ao ano" }.freeze
  STATUS_LABEL = { "ativo" => "Ativo", "resgatado" => "Resgatado" }.freeze

  validates :instituicao, presence: true
  validates :taxa_rendimento, presence: true, numericality: { greater_than: 0 }
  validates :periodicidade_taxa, presence: true
  validates :status, presence: true
  validates :valor_resgatado, numericality: { greater_than: 0 }, allow_nil: true
  validar_par_preenchido :valor_resgatado, :data_resgate

  def periodicidade_taxa_label
    PERIODICIDADE_LABEL.fetch(periodicidade_taxa)
  end

  def status_label
    STATUS_LABEL.fetch(status)
  end
end
