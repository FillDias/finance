class DespesasController < ApplicationController
  before_action :set_despesa, only: [ :edit, :update, :destroy ]

  def index
    @despesa = Despesa.new
    @cartoes = Cartao.order(:nome)
    carregar_lista_filtrada
  end

  def create
    resultado = CriarDespesa.call(**despesa_params)

    if resultado.sucesso?
      redirect_to despesas_path, notice: "Despesa registrada."
    elsif resultado.valor.is_a?(Despesa)
      @despesa = resultado.valor
      @cartoes = Cartao.order(:nome)
      carregar_lista_filtrada
      render :index, status: :unprocessable_entity
    else
      redirect_to despesas_path, alert: resultado.erros.join(", ")
    end
  end

  def edit
    @categorias = Categoria.order(:nome)
  end

  def update
    resultado = AtualizarDespesa.call(despesa: @despesa, **despesa_params_edicao)

    if resultado.sucesso?
      redirect_to despesas_path, notice: "Despesa atualizada."
    else
      @despesa = resultado.valor
      @categorias = Categoria.order(:nome)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    ExcluirDespesa.call(despesa: @despesa)
    redirect_to despesas_path, notice: "Despesa removida."
  end

  def exportar
    resultado = ExportarRelatorioXlsx.call(abas: [ :despesas ])
    enviar_xlsx(resultado.valor, "despesas")
  end

  private

  def set_despesa
    @despesa = Despesa.find(params[:id])
  end

  def carregar_lista_filtrada
    @categorias = Categoria.order(:nome)
    @categoria_id = params[:categoria_id].presence
    @data_inicio = params[:data_inicio].presence
    @data_fim = params[:data_fim].presence
    @despesas = DespesasFiltradas.call(categoria_id: @categoria_id, data_inicio: @data_inicio, data_fim: @data_fim)
  end

  def despesa_params
    params.require(:despesa)
          .permit(:valor, :data, :categoria_id, :tipo, :forma_pagamento, :dia_vencimento, :cartao_id, :parcelado, :numero_parcelas)
          .to_h.symbolize_keys
  end

  def despesa_params_edicao
    params.require(:despesa).permit(:valor, :data, :categoria_id, :tipo, :forma_pagamento, :dia_vencimento).to_h.symbolize_keys
  end
end
