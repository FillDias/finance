class DespesasFiltradas < ApplicationQuery
  def initialize(categoria_id: nil, cartao_id: nil, data_inicio: nil, data_fim: nil)
    @categoria_id = categoria_id
    @cartao_id = cartao_id
    @data_inicio = data_inicio
    @data_fim = data_fim
  end

  def call
    # Filtro por Cartão só faz sentido pra Compra (Despesa, Parcelamento e
    # Emprestimo não pertencem a nenhum Cartão) — com o filtro ativo, a
    # lista vira só as compras dele.
    itens = @cartao_id.present? ? compras_listadas : despesas_listadas + compras_listadas + parcelamentos_listados + emprestimos_listados
    itens.sort_by(&:data).reverse
  end

  private

  def despesas_listadas
    relacao = Despesa.includes(:categoria)
    relacao = relacao.where(categoria_id: @categoria_id) if @categoria_id.present?
    relacao = relacao.where(data: periodo) if periodo

    relacao.map do |despesa|
      DespesaListada.new(
        data: despesa.data, categoria_nome: despesa.categoria.nome, tipo_label: despesa.tipo_label,
        forma_pagamento_label: despesa.forma_pagamento_label, valor: despesa.valor, registro: despesa
      )
    end
  end

  # Compras com categoria são as que vieram de uma Despesa paga no cartão
  # (ver CriarDespesa / ticket #9) — aparecem aqui em vez de num registro
  # Despesa separado, pra não contar o gasto duas vezes.
  def compras_listadas
    relacao = Compra.includes(:categoria, :cartao).where.not(categoria_id: nil)
    relacao = relacao.where(categoria_id: @categoria_id) if @categoria_id.present?
    relacao = relacao.where(cartao_id: @cartao_id) if @cartao_id.present?
    relacao = relacao.where(data_compra: periodo) if periodo

    relacao.map do |compra|
      DespesaListada.new(
        data: compra.data_compra, categoria_nome: compra.categoria.nome, tipo_label: compra.tipo_label,
        forma_pagamento_label: "Cartão #{compra.cartao.nome}", valor: compra.valor_total, registro: compra
      )
    end
  end

  def parcelamentos_listados
    relacao = Parcelamento.includes(:categoria)
    relacao = relacao.where(categoria_id: @categoria_id) if @categoria_id.present?
    relacao = relacao.where(data: periodo) if periodo

    relacao.map do |parcelamento|
      DespesaListada.new(
        data: parcelamento.data, categoria_nome: parcelamento.categoria.nome, tipo_label: parcelamento.tipo_label,
        forma_pagamento_label: parcelamento.forma_pagamento_label, valor: parcelamento.valor_total, registro: parcelamento
      )
    end
  end

  # Diferente de compras_listadas/parcelamentos_listados (uma linha por
  # registro, na sua própria data), Emprestimo lista uma linha por Parcela —
  # não tem um único "data" de lançamento (o cronograma inteiro é cadastrado
  # de uma vez, ver CriarEmprestimo), então cada parcela aparece no mês do
  # seu próprio vencimento, igual ao que já conta pra Saídas do mês.
  def emprestimos_listados
    relacao = Emprestimo.includes(:categoria, :parcelas)
    relacao = relacao.where(categoria_id: @categoria_id) if @categoria_id.present?

    relacao.flat_map do |emprestimo|
      parcelas = emprestimo.parcelas
      parcelas = parcelas.select { |parcela| periodo.cover?(parcela.data_vencimento) } if periodo
      parcelas.map { |parcela| linha_emprestimo(emprestimo, parcela) }
    end
  end

  def linha_emprestimo(emprestimo, parcela)
    DespesaListada.new(
      data: parcela.data_vencimento, categoria_nome: emprestimo.categoria.nome, tipo_label: "Fixa",
      forma_pagamento_label: "Empréstimo #{emprestimo.nome}", valor: parcela.valor, registro: emprestimo
    )
  end

  def periodo
    return nil if @data_inicio.blank? && @data_fim.blank?

    inicio = @data_inicio.presence || Date.new(1, 1, 1)
    fim = @data_fim.presence || Date.new(9999, 12, 31)
    inicio.to_date..fim.to_date
  end
end
