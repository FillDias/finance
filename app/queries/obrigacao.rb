Obrigacao = Struct.new(:valor, :vencimento, :status, :origem, :registro, keyword_init: true) do
  def pendente?
    status == :pendente
  end

  def paga?
    status == :paga
  end

  def atrasada?
    status == :atrasada
  end
end
