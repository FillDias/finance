class RendasController < ApplicationController
  before_action :set_renda, only: [ :edit, :update, :destroy ]

  def index
    @renda = Renda.new
    carregar_lista_e_totais
  end

  def create
    resultado = CriarRenda.call(**renda_params)

    if resultado.sucesso?
      redirect_to rendas_path, notice: "Renda registrada."
    else
      @renda = resultado.valor
      carregar_lista_e_totais
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    resultado = AtualizarRenda.call(renda: @renda, **renda_params)

    if resultado.sucesso?
      redirect_to rendas_path, notice: "Renda atualizada."
    else
      @renda = resultado.valor
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    ExcluirRenda.call(renda: @renda)
    redirect_to rendas_path, notice: "Renda removida."
  end

  private

  def set_renda
    @renda = Renda.find(params[:id])
  end

  def carregar_lista_e_totais
    @rendas = Renda.order(data: :desc)
    @total_por_fonte = TotalDeRendaPorFonte.call(ano: Date.current.year)
  end

  def renda_params
    params.require(:renda).permit(:valor, :data, :fonte).to_h.symbolize_keys
  end
end
