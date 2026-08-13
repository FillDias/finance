class TaxaCdiController < ApplicationController
  def update
    resultado = AtualizarTaxaCdi.call(**taxa_cdi_params)

    if resultado.sucesso?
      redirect_to investimentos_path, notice: "Taxa CDI atualizada."
    else
      redirect_to investimentos_path, alert: resultado.erros.join(", ")
    end
  end

  private

  def taxa_cdi_params
    params.require(:taxa_cdi).permit(:valor).to_h.symbolize_keys
  end
end
