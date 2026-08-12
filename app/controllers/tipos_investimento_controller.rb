class TiposInvestimentoController < ApplicationController
  before_action :set_tipo_investimento, only: [ :edit, :update, :destroy ]

  def index
    @tipo_investimento = TipoInvestimento.new
    @tipos_investimento = TipoInvestimento.order(:nome)
  end

  def create
    resultado = CriarTipoInvestimento.call(**tipo_investimento_params)

    if resultado.sucesso?
      redirect_to tipos_investimento_path, notice: "Tipo de investimento criado."
    else
      @tipo_investimento = resultado.valor
      @tipos_investimento = TipoInvestimento.order(:nome)
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    resultado = AtualizarTipoInvestimento.call(tipo_investimento: @tipo_investimento, **tipo_investimento_params)

    if resultado.sucesso?
      redirect_to tipos_investimento_path, notice: "Tipo de investimento atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    resultado = ExcluirTipoInvestimento.call(tipo_investimento: @tipo_investimento)

    if resultado.sucesso?
      redirect_to tipos_investimento_path, notice: "Tipo de investimento removido."
    else
      redirect_to tipos_investimento_path, alert: resultado.erros.join(", ")
    end
  end

  private

  def set_tipo_investimento
    @tipo_investimento = TipoInvestimento.find(params[:id])
  end

  def tipo_investimento_params
    params.require(:tipo_investimento).permit(:nome).to_h.symbolize_keys
  end
end
