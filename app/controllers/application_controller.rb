class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :autenticar_http_basic
  before_action :exigir_perfil

  private

  # Só em produção — protege a URL pública contra gente de fora (ver ADR
  # 0007). Credenciais em ENV, nunca no código; falha alto (erro de
  # configuração) em vez de rodar sem proteção se faltarem.
  def autenticar_http_basic
    return unless Rails.env.production?

    usuario = ENV.fetch("HTTP_BASIC_AUTH_USER")
    senha = ENV.fetch("HTTP_BASIC_AUTH_PASSWORD")

    authenticate_or_request_with_http_basic do |usuario_informado, senha_informada|
      ActiveSupport::SecurityUtils.secure_compare(usuario_informado, usuario) &
        ActiveSupport::SecurityUtils.secure_compare(senha_informada, senha)
    end
  end

  def exigir_perfil
    Current.perfil = Perfil.find_by(id: session[:perfil_id])
    redirect_to perfis_path unless Current.perfil
  end

  def enviar_xlsx(package, nome_arquivo)
    send_data package.to_stream.read, filename: "#{nome_arquivo}.xlsx", type: ExportarRelatorioXlsx::CONTENT_TYPE
  end
end
