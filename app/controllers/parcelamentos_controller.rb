class ParcelamentosController < ApplicationController
  def destroy
    parcelamento = Parcelamento.find(params[:id])
    ExcluirParcelamento.call(parcelamento: parcelamento)
    redirect_back fallback_location: despesas_path, notice: "Parcelamento removido."
  end
end
