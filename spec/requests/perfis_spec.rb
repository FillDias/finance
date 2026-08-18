require "rails_helper"

RSpec.describe "Perfis", type: :request do
  describe "GET /perfis" do
    it "lista os perfis cadastrados, sem exigir um perfil já selecionado", sem_perfil: true do
      Perfil.create!(nome: "Fill")
      Perfil.create!(nome: "Fernanda")

      get perfis_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Fill")
      expect(response.body).to include("Fernanda")
    end
  end

  describe "POST /perfis/:id/selecionar" do
    it "guarda o perfil na sessão e redireciona pro Painel" do
      perfil = Perfil.create!(nome: "Fill")

      post selecionar_perfil_path(perfil)

      expect(response).to redirect_to(root_path)
      expect(session[:perfil_id]).to eq(perfil.id)
    end
  end

  describe "sem perfil selecionado", sem_perfil: true do
    it "redireciona qualquer outra tela pra /perfis" do
      get despesas_path

      expect(response).to redirect_to(perfis_path)
    end

    it "não redireciona depois que um perfil é selecionado" do
      perfil = Perfil.create!(nome: "Fill")
      post selecionar_perfil_path(perfil)

      get despesas_path

      expect(response).to have_http_status(:ok)
    end
  end
end
