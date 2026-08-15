class EmprestimosController < ApplicationController
  before_action :set_emprestimo, only: [ :show ]

  def index
    @emprestimo = Emprestimo.new
    @credores = Credor.order(:nome)
    @categorias = Categoria.order(:nome)
    @emprestimos = Emprestimo.includes(:credor, :categoria).order(:nome)
  end

  def show
    @parcelas = @emprestimo.parcelas.order(:data_vencimento)
  end

  def create
    resultado = CriarEmprestimo.call(**emprestimo_params)

    if resultado.sucesso?
      redirect_to emprestimos_path, notice: "Empréstimo criado."
    else
      @emprestimo = resultado.valor
      @erros = resultado.erros
      @credores = Credor.order(:nome)
      @categorias = Categoria.order(:nome)
      @emprestimos = Emprestimo.includes(:credor, :categoria).order(:nome)
      render :index, status: :unprocessable_entity
    end
  end

  def exportar
    resultado = ExportarRelatorioXlsx.call(abas: [ :emprestimos ])
    enviar_xlsx(resultado.valor, "emprestimos")
  end

  private

  def set_emprestimo
    @emprestimo = Emprestimo.find(params[:id])
  end

  def emprestimo_params
    params.require(:emprestimo).permit(:nome, :credor_id, :categoria_id, :valor_total, :cronograma_texto).to_h.symbolize_keys
  end
end
