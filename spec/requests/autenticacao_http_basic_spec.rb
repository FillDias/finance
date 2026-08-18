require "rails_helper"

# Só ativa em produção (ver ADR 0007) — simula isso virando Rails.env pra
# "production" só durante este arquivo, sem depender de nenhum boot real
# em modo produção.
RSpec.describe "Autenticação HTTP Basic", type: :request, sem_perfil: true do
  around do |example|
    ambiente_original = Rails.env
    Rails.env = "production"
    example.run
  ensure
    Rails.env = ambiente_original
  end

  before do
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with("HTTP_BASIC_AUTH_USER").and_return("usuario_teste")
    allow(ENV).to receive(:fetch).with("HTTP_BASIC_AUTH_PASSWORD").and_return("senha_teste")
  end

  it "bloqueia sem credenciais" do
    get perfis_path

    expect(response).to have_http_status(:unauthorized)
  end

  it "bloqueia com credenciais erradas" do
    get perfis_path, headers: { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials("usuario_teste", "errada") }

    expect(response).to have_http_status(:unauthorized)
  end

  it "libera com as credenciais certas" do
    get perfis_path, headers: { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials("usuario_teste", "senha_teste") }

    expect(response).to have_http_status(:ok)
  end

  it "não bloqueia fora de produção (ambiente de test/development)" do
    Rails.env = "test"

    get perfis_path

    expect(response).to have_http_status(:ok)
  end
end
