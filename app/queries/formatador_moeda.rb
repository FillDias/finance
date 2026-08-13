# Formata valores em BRL pra tooltip/label de gráfico — fora de uma view,
# então não dá pra usar o helper `moeda` (ActionView) direto.
module FormatadorMoeda
  def self.para(valor)
    ActiveSupport::NumberHelper.number_to_currency(valor, unit: "R$ ", separator: ",", delimiter: ".")
  end
end
