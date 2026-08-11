class FaturasController < ApplicationController
  def pagar
    resultado = MarcarFaturaComoPaga.call(cartao_id: params[:cartao_id], **fatura_params)

    if resultado.sucesso?
      redirect_to cartao_path(params[:cartao_id]), notice: "Fatura marcada como paga."
    else
      redirect_to cartao_path(params[:cartao_id]), alert: resultado.erros.join(", ")
    end
  end

  private

  def fatura_params
    params.require(:fatura).permit(:mes_referencia, :valor_pago, :data_pagamento).to_h.symbolize_keys
  end
end
