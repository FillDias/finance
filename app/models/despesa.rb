class Despesa < ApplicationRecord
  belongs_to :categoria

  enum :tipo, { fixa: 0, variavel: 1 }
  enum :forma_pagamento, { debito: 0, boleto: 1, pix: 2, dinheiro: 3 }

  TIPO_LABEL = { "fixa" => "Fixa", "variavel" => "Variável" }.freeze
  FORMA_PAGAMENTO_LABEL = { "debito" => "Débito", "boleto" => "Boleto", "pix" => "PIX", "dinheiro" => "Dinheiro" }.freeze

  validates :valor, presence: true, numericality: { greater_than: 0 }
  validates :data, presence: true
  validates :tipo, presence: true
  validates :forma_pagamento, presence: true
  validates :dia_vencimento,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 31 },
            if: :fixa?

  def tipo_label
    TIPO_LABEL.fetch(tipo)
  end

  def forma_pagamento_label
    FORMA_PAGAMENTO_LABEL.fetch(forma_pagamento)
  end
end
