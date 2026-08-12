class ParcelasController < ApplicationController
  def pagar
    parcela = Parcela.find(params[:id])
    resultado = MarcarParcelaComoPaga.call(parcela: parcela, data_pagamento: params[:data_pagamento].presence || Date.current)

    if resultado.sucesso?
      redirect_to redirecionamento_apos_pagamento(parcela), notice: "Parcela paga."
    else
      redirect_to redirecionamento_apos_pagamento(parcela), alert: resultado.erros.join(", ")
    end
  end

  private

  def redirecionamento_apos_pagamento(parcela)
    parcela.origem_emprestimo? ? emprestimo_path(parcela.origem) : root_path
  end
end
