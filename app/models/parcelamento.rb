class Parcelamento < ApplicationRecord
  include ClassificacaoFixaVariavel

  belongs_to :categoria
  has_many :parcelas, as: :origem, dependent: :destroy

  enum :forma_pagamento, { debito: 0, boleto: 1, pix: 2, dinheiro: 3 }

  FORMA_PAGAMENTO_LABEL = { "debito" => "Débito", "boleto" => "Boleto", "pix" => "PIX", "dinheiro" => "Dinheiro" }.freeze

  validates :data, presence: true
  validates :valor_total, presence: true, numericality: { greater_than: 0 }
  validates :numero_parcelas, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 2 }
  validates :forma_pagamento, presence: true

  def forma_pagamento_label
    FORMA_PAGAMENTO_LABEL.fetch(forma_pagamento)
  end
end
