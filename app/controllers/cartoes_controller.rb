class CartoesController < ApplicationController
  before_action :set_cartao, only: [ :show, :edit, :update ]

  def index
    @cartao = Cartao.new
    @credores = Credor.order(:nome)
    @cartoes = Cartao.includes(:credor).order(:nome)
  end

  def show
    @saldos_herdados = @cartao.saldos_herdados.order(mes_referencia: :desc)
    @novo_saldo_herdado = SaldoHerdado.new(cartao_id: @cartao.id)
  end

  def create
    resultado = CriarCartao.call(**cartao_params)

    if resultado.sucesso?
      redirect_to cartoes_path, notice: "Cartão criado."
    else
      @cartao = resultado.valor
      @credores = Credor.order(:nome)
      @cartoes = Cartao.includes(:credor).order(:nome)
      render :index, status: :unprocessable_entity
    end
  end

  def edit
    @credores = Credor.order(:nome)
  end

  def update
    resultado = AtualizarCartao.call(cartao: @cartao, **cartao_params)

    if resultado.sucesso?
      redirect_to cartoes_path, notice: "Cartão atualizado."
    else
      @cartao = resultado.valor
      @credores = Credor.order(:nome)
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_cartao
    @cartao = Cartao.find(params[:id])
  end

  def cartao_params
    params.require(:cartao).permit(:nome, :credor_id, :limite_total, :dia_fechamento, :dia_vencimento, :data_corte).to_h.symbolize_keys
  end
end
