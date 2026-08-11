class CredoresController < ApplicationController
  before_action :set_credor, only: [ :show, :edit, :update ]

  def index
    @credor = Credor.new
    @credores = Credor.order(:nome)
  end

  def show
    @cartoes = @credor.cartoes.order(:nome)
    @emprestimos = @credor.emprestimos.order(:nome)
  end

  def create
    resultado = CriarCredor.call(**credor_params)

    if resultado.sucesso?
      redirect_to credores_path, notice: "Credor criado."
    else
      @credor = resultado.valor
      @credores = Credor.order(:nome)
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    resultado = AtualizarCredor.call(credor: @credor, **credor_params)

    if resultado.sucesso?
      redirect_to credores_path, notice: "Credor atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_credor
    @credor = Credor.find(params[:id])
  end

  def credor_params
    params.require(:credor).permit(:nome).to_h.symbolize_keys
  end
end
