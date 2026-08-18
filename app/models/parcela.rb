class Parcela < ApplicationRecord
  include PertenceAPerfil

  belongs_to :origem, polymorphic: true

  enum :status, { pendente: 0, paga: 1 }

  STATUS_LABEL = { "pendente" => "Pendente", "paga" => "Paga" }.freeze

  validates :valor, presence: true, numericality: { greater_than: 0 }
  validates :data_vencimento, presence: true
  # Defesa a mais além do default_scope (ver ADR 0007): uma Parcela nunca
  # pode ficar com um Perfil diferente do lançamento que a originou.
  validate :perfil_bate_com_a_origem

  def atrasada?
    pendente? && data_vencimento < Date.current
  end

  def origem_emprestimo?
    origem.is_a?(Emprestimo)
  end

  def origem_parcelamento?
    origem.is_a?(Parcelamento)
  end

  def status_label
    return "Atrasada" if atrasada?

    STATUS_LABEL.fetch(status)
  end

  private

  def perfil_bate_com_a_origem
    return if origem.blank? || perfil_id.blank?

    errors.add(:perfil, "precisa ser o mesmo Perfil da origem (#{origem.class.name})") if perfil_id != origem.perfil_id
  end
end
