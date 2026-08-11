class Despesa < ApplicationRecord
  include ClassificacaoFixaVariavel

  belongs_to :categoria

  enum :forma_pagamento, { debito: 0, boleto: 1, pix: 2, dinheiro: 3 }

  FORMA_PAGAMENTO_LABEL = { "debito" => "Débito", "boleto" => "Boleto", "pix" => "PIX", "dinheiro" => "Dinheiro" }.freeze

  validates :valor, presence: true, numericality: { greater_than: 0 }
  validates :data, presence: true
  validates :tipo, presence: true
  validates :forma_pagamento, presence: true
  validates :dia_vencimento,
            presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 31 },
            if: :fixa?

  def forma_pagamento_label
    FORMA_PAGAMENTO_LABEL.fetch(forma_pagamento)
  end
end
