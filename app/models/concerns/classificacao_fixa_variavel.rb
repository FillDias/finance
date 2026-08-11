module ClassificacaoFixaVariavel
  extend ActiveSupport::Concern

  TIPO_LABEL = { "fixa" => "Fixa", "variavel" => "Variável" }.freeze

  included do
    enum :tipo, { fixa: 0, variavel: 1 }
  end

  def tipo_label
    return nil if tipo.nil?

    TIPO_LABEL.fetch(tipo)
  end
end
