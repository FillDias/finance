class ComprasController < ApplicationController
  def create
    resultado = CriarCompraNoCartao.call(cartao_id: params[:cartao_id], **compra_params)

    if resultado.sucesso?
      redirect_to cartao_path(params[:cartao_id]), notice: "Compra lançada."
    else
      redirect_to cartao_path(params[:cartao_id]), alert: resultado.erros.join(", ")
    end
  end

  private

  def compra_params
    params.require(:compra).permit(:data_compra, :valor_total, :parcelado, :numero_parcelas).to_h.symbolize_keys
  end
end
