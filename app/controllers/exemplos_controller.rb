class ExemplosController < ApplicationController
  def grafico
    @opcao_grafico = GraficoExemploQuery.call
  end
end
