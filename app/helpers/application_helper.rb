module ApplicationHelper
  def moeda(valor)
    number_to_currency(valor, unit: "R$ ", separator: ",", delimiter: ".")
  end

  def taxa_rendimento(investimento)
    "#{number_with_precision(investimento.taxa_rendimento, precision: 3)}#{investimento.periodicidade_taxa_label}"
  end
end
