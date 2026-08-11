DespesaListada = Struct.new(
  :data, :categoria_nome, :tipo_label, :forma_pagamento_label, :valor, :registro,
  keyword_init: true
) do
  def despesa?
    registro.is_a?(Despesa)
  end
end
