class DespesasController < ApplicationController
  before_action :set_despesa, only: [ :edit, :update, :destroy ]

  def index
    @despesa = Despesa.new
    @categorias = Categoria.order(:nome)
    @categoria_id = params[:categoria_id].presence
    @data_inicio = params[:data_inicio].presence
    @data_fim = params[:data_fim].presence
    @despesas = DespesasFiltradas.call(categoria_id: @categoria_id, periodo: periodo_do_filtro)
  end

  def create
    resultado = CriarDespesa.call(**despesa_params)

    if resultado.sucesso?
      redirect_to despesas_path, notice: "Despesa registrada."
    else
      @despesa = resultado.valor
      @categorias = Categoria.order(:nome)
      @despesas = DespesasFiltradas.call
      render :index, status: :unprocessable_entity
    end
  end

  def edit
    @categorias = Categoria.order(:nome)
  end

  def update
    resultado = AtualizarDespesa.call(despesa: @despesa, **despesa_params)

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

  private

  def set_despesa
    @despesa = Despesa.find(params[:id])
  end

  def periodo_do_filtro
    return nil if @data_inicio.blank? && @data_fim.blank?

    Date.parse(@data_inicio.presence || "0001-01-01")..Date.parse(@data_fim.presence || "9999-12-31")
  end

  def despesa_params
    params.require(:despesa).permit(:valor, :data, :categoria_id, :tipo, :forma_pagamento, :dia_vencimento).to_h.symbolize_keys
  end
end
