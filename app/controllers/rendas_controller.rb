class RendasController < ApplicationController
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
    @renda = Renda.find(params[:id])
  end

  def update
    renda = Renda.find(params[:id])
    resultado = AtualizarRenda.call(renda: renda, **renda_params)

    if resultado.sucesso?
      redirect_to rendas_path, notice: "Renda atualizada."
    else
      @renda = resultado.valor
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    renda = Renda.find(params[:id])
    ExcluirRenda.call(renda: renda)
    redirect_to rendas_path, notice: "Renda removida."
  end

  private

  def carregar_lista_e_totais
    @rendas = Renda.order(data: :desc)
    @total_por_fonte = TotalDeRendaPorFonte.call(ano: Date.current.year)
  end

  def renda_params
    params.require(:renda).permit(:valor, :data, :fonte).to_h.symbolize_keys
  end
end
