class Resultado
  attr_reader :valor, :erros

  def self.sucesso(valor: nil)
    new(sucesso: true, valor: valor)
  end

  def self.erro(*erros)
    new(sucesso: false, erros: erros.flatten)
  end

  def sucesso?
    @sucesso
  end

  def erro?
    !sucesso?
  end

  private

  def initialize(sucesso:, valor: nil, erros: [])
    @sucesso = sucesso
    @valor = valor
    @erros = erros
  end
end
