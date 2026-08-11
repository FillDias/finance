class SaldosHerdadosController < ApplicationController
  before_action :set_saldo_herdado, only: [ :quitar ]

  def create
    resultado = CriarSaldoHerdado.call(**saldo_herdado_params)
    cartao = Cartao.find(saldo_herdado_params[:cartao_id])

    if resultado.sucesso?
      redirect_to cartao_path(cartao), notice: "Saldo herdado lançado."
    else
      redirect_to cartao_path(cartao), alert: resultado.erros.join(", ")
    end
  end

  def novo_importar
  end

  def importar
    arquivo = params[:arquivo]

    if arquivo.blank?
      redirect_to novo_importar_saldo_herdado_path, alert: "Selecione um arquivo CSV."
      return
    end

    resultado = ImportarSaldoHerdado.call(conteudo_csv: arquivo.read)

    if resultado.sucesso?
      redirect_to cartoes_path, notice: "#{resultado.valor} saldo(s) herdado(s) importado(s) com sucesso."
    else
      @erros = resultado.erros
      render :novo_importar, status: :unprocessable_entity
    end
  end

  def quitar
    resultado = QuitarSaldoHerdado.call(saldo_herdado: @saldo_herdado, valor_pago: params[:valor_pago], data_pagamento: params[:data_pagamento])

    if resultado.sucesso?
      redirect_to cartao_path(@saldo_herdado.cartao), notice: "Saldo herdado quitado."
    else
      redirect_to cartao_path(@saldo_herdado.cartao), alert: resultado.erros.join(", ")
    end
  end

  private

  def set_saldo_herdado
    @saldo_herdado = SaldoHerdado.find(params[:id])
  end

  def saldo_herdado_params
    params.require(:saldo_herdado).permit(:cartao_id, :mes_referencia, :valor_total).to_h.symbolize_keys
  end
end
