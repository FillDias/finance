require "rails_helper"

RSpec.describe "Exportação XLSX", type: :request do
  it "GET /receitas/exportar baixa um XLSX só com a aba Receitas" do
    get exportar_rendas_path

    expect(response).to have_http_status(:ok)
    expect(response.content_type).to eq(ExportarRelatorioXlsx::CONTENT_TYPE)
    expect(response.headers["Content-Disposition"]).to include("receitas.xlsx")
  end

  it "GET /despesas/exportar baixa um XLSX só com a aba Despesas" do
    get exportar_despesas_path

    expect(response).to have_http_status(:ok)
    expect(response.headers["Content-Disposition"]).to include("despesas.xlsx")
  end

  it "GET /cartoes/exportar baixa um XLSX só com a aba Cartões" do
    get exportar_cartoes_path

    expect(response).to have_http_status(:ok)
    expect(response.headers["Content-Disposition"]).to include("cartoes.xlsx")
  end

  it "GET /emprestimos/exportar baixa um XLSX só com a aba Empréstimos" do
    get exportar_emprestimos_path

    expect(response).to have_http_status(:ok)
    expect(response.headers["Content-Disposition"]).to include("emprestimos.xlsx")
  end

  it "GET /exportar (Painel) baixa um XLSX com todas as abas" do
    get exportar_painel_path

    expect(response).to have_http_status(:ok)
    expect(response.headers["Content-Disposition"]).to include("relatorio-financeiro.xlsx")
  end
end
