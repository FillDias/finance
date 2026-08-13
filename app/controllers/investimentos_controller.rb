class InvestimentosController < ApplicationController
  before_action :set_investimento, only: [ :show, :edit, :update, :resgatar ]

  def index
    @investimento = Investimento.new
    carregar_dados_index
  end

  def show
    @aportes = @investimento.aportes.order(data: :desc)
    @novo_aporte = Aporte.new
  end

  def create
    resultado = CriarInvestimento.call(**investimento_params)

    if resultado.sucesso?
      redirect_to investimentos_path, notice: "Investimento criado."
    else
      @investimento = resultado.valor
      carregar_dados_index
      render :index, status: :unprocessable_entity
    end
  end

  def edit
    @tipos_investimento = TipoInvestimento.order(:nome)
  end

  def update
    resultado = AtualizarInvestimento.call(investimento: @investimento, **investimento_params)

    if resultado.sucesso?
      redirect_to investimentos_path, notice: "Investimento atualizado."
    else
      @investimento = resultado.valor
      @tipos_investimento = TipoInvestimento.order(:nome)
      render :edit, status: :unprocessable_entity
    end
  end

  def resgatar
    resultado = ResgatarInvestimento.call(investimento: @investimento, **resgate_params)

    if resultado.sucesso?
      redirect_to investimentos_path, notice: "Investimento resgatado."
    else
      redirect_to investimentos_path, alert: resultado.erros.join(", ")
    end
  end

  private

  def carregar_dados_index
    @tipos_investimento = TipoInvestimento.order(:nome)
    @investimentos = Investimento.includes(:tipo_investimento).order(:instituicao)
    @taxa_cdi = TaxaCdi.atual
    @total_investido = TotalInvestidoQuery.call
    @grafico_sparkline_total = GraficoSparklineTotalInvestidoQuery.call
    @grafico_evolucao_aportes = GraficoEvolucaoAportesQuery.call
    @grafico_distribuicao_por_tipo = GraficoDistribuicaoPorTipoQuery.call
    @comparacoes_cdi = ComparacaoCdiQuery.call
  end

  def set_investimento
    @investimento = Investimento.find(params[:id])
  end

  def investimento_params
    params.require(:investimento).permit(:tipo_investimento_id, :instituicao, :taxa_rendimento, :periodicidade_taxa, :data_vencimento).to_h.symbolize_keys
  end

  def resgate_params
    params.require(:investimento).permit(:valor_resgatado, :data_resgate).to_h.symbolize_keys
  end
end
