class DespesasFiltradas < ApplicationQuery
  def initialize(categoria_id: nil, periodo: nil)
    @categoria_id = categoria_id
    @periodo = periodo
  end

  def call
    relacao = Despesa.includes(:categoria).order(data: :desc)
    relacao = relacao.where(categoria_id: @categoria_id) if @categoria_id.present?
    relacao = relacao.where(data: @periodo) if @periodo.present?
    relacao.to_a
  end
end
