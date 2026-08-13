# pago nil = ainda não venceu/não foi pago; variação só existe uma vez que
# houve pagamento (comparar previsto x pago antes disso não faz sentido).
LinhaCentralObrigacoes = Struct.new(:origem, :descricao, :vencimento, :previsto, :pago, :status, keyword_init: true) do
  def variacao
    return nil if pago.nil?

    pago - previsto
  end

  def paga?
    status == :paga
  end
end
