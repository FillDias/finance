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
    @compras = @cartao.compras.includes(:parcelas).order(data_compra: :desc)
    @nova_compra = Compra.new
    @faturas = meses_com_fatura.map { |mes| FaturaProjetadaQuery.call(cartao: @cartao, mes: mes) }
    @saldo_restante = SaldoRestanteQuery.call(cartao: @cartao)
    @utilizacao_limite = UtilizacaoLimiteQuery.call(cartao: @cartao)
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

  def meses_com_fatura
    meses_do_saldo_herdado = @cartao.saldos_herdados.pluck(:mes_referencia)
    meses_das_parcelas = @cartao.parcelas.pluck(:data_vencimento).map(&:beginning_of_month)
    (meses_do_saldo_herdado + meses_das_parcelas).uniq.sort
  end

  def cartao_params
    params.require(:cartao).permit(:nome, :credor_id, :limite_total, :dia_fechamento, :dia_vencimento, :data_corte).to_h.symbolize_keys
  end
end
