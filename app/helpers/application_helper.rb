module ApplicationHelper
  def moeda(valor)
    number_to_currency(valor, unit: "R$ ", separator: ",", delimiter: ".")
  end

  def taxa_rendimento(investimento)
    "#{number_with_precision(investimento.taxa_rendimento, precision: 3)}#{investimento.periodicidade_taxa_label}"
  end

  # Pra Entradas/Saldo um aumento é bom (aumento_e_bom: true); pra Saídas um
  # aumento é ruim (aumento_e_bom: false) — a mesma comparação de período
  # precisa de cores opostas dependendo da métrica.
  def cor_variacao(delta, aumento_e_bom:)
    favoravel = aumento_e_bom ? !delta.negative? : !delta.positive?
    favoravel ? "cor-positiva" : "cor-negativa"
  end
end
