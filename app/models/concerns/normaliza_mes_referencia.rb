module NormalizaMesReferencia
  extend ActiveSupport::Concern

  included do
    before_validation :normalizar_mes_referencia
  end

  private

  def normalizar_mes_referencia
    self.mes_referencia = mes_referencia.beginning_of_month if mes_referencia.present?
  end
end
