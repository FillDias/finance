class AportesController < ApplicationController
  before_action :set_investimento
  before_action :set_aporte, only: [ :edit, :update, :destroy ]

  def create
    resultado = CriarAporte.call(investimento_id: @investimento.id, **aporte_params)

    if resultado.sucesso?
      redirect_to investimento_path(@investimento), notice: "Aporte registrado."
    else
      redirect_to investimento_path(@investimento), alert: resultado.erros.join(", ")
    end
  end

  def edit
  end

  def update
    resultado = AtualizarAporte.call(aporte: @aporte, **aporte_params)

    if resultado.sucesso?
      redirect_to investimento_path(@investimento), notice: "Aporte atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    ExcluirAporte.call(aporte: @aporte)
    redirect_to investimento_path(@investimento), notice: "Aporte removido."
  end

  private

  def set_investimento
    @investimento = Investimento.find(params[:investimento_id])
  end

  def set_aporte
    @aporte = @investimento.aportes.find(params[:id])
  end

  def aporte_params
    params.require(:aporte).permit(:valor, :data).to_h.symbolize_keys
  end
end
