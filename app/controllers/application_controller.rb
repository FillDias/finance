class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def enviar_xlsx(package, nome_arquivo)
    send_data package.to_stream.read, filename: "#{nome_arquivo}.xlsx", type: ExportarRelatorioXlsx::CONTENT_TYPE
  end
end
