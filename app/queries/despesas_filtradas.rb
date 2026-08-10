class DespesasFiltradas < ApplicationQuery
  def initialize(categoria_id: nil, data_inicio: nil, data_fim: nil)
    @categoria_id = categoria_id
    @data_inicio = data_inicio
    @data_fim = data_fim
  end

  def call
    relacao = Despesa.includes(:categoria).order(data: :desc)
    relacao = relacao.where(categoria_id: @categoria_id) if @categoria_id.present?
    relacao = relacao.where(data: periodo) if periodo
    relacao.to_a
  end

  private

  def periodo
    return nil if @data_inicio.blank? && @data_fim.blank?

    inicio = @data_inicio.presence || Date.new(1, 1, 1)
    fim = @data_fim.presence || Date.new(9999, 12, 31)
    inicio.to_date..fim.to_date
  end
end
