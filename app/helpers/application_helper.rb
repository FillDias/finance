module ApplicationHelper
  def moeda(valor)
    number_to_currency(valor, unit: "R$ ", separator: ",", delimiter: ".")
  end
end
