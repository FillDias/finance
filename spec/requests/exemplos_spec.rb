require "rails_helper"

RSpec.describe "Exemplos", type: :request do
  describe "GET /exemplo-grafico" do
    it "renderiza a página com o data-controller e a opção do ECharts serializada" do
      Renda.create!(valor: 1000, data: Date.current, fonte: "Salário")

      get exemplo_grafico_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('data-controller="chart"')
      expect(response.body).to include("data-chart-option-value=")
      expect(response.body).to include("Salário")
    end
  end
end
