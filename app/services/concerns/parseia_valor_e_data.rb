module ParseiaValorEData
  private

  def parsear_data(valor)
    texto = valor.to_s.strip
    texto = "#{texto}-01" if texto.match?(/\A\d{4}-\d{2}\z/)
    Date.parse(texto)
  rescue ArgumentError, TypeError
    nil
  end

  def parsear_valor(valor)
    Float(valor.to_s.strip)
  rescue ArgumentError, TypeError
    nil
  end
end
