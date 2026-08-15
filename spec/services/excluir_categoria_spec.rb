require "rails_helper"

RSpec.describe ExcluirCategoria do
  it "remove a categoria sem despesas associadas" do
    categoria = Categoria.create!(nome: "Lazer")

    resultado = ExcluirCategoria.call(categoria: categoria)

    expect(resultado).to be_sucesso
    expect(Categoria.exists?(categoria.id)).to be false
  end

  it "retorna erro e mantém a categoria quando há despesas associadas" do
    categoria = Categoria.create!(nome: "Moradia")
    Despesa.create!(valor: 100, data: Date.current, categoria: categoria, tipo: :variavel, forma_pagamento: :dinheiro)

    resultado = ExcluirCategoria.call(categoria: categoria)

    expect(resultado).to be_erro
    expect(Categoria.exists?(categoria.id)).to be true
  end

  # Regressão: Compra e Parcelamento já tinham a FK pra categorias sem o
  # has_many correspondente em Categoria — excluir uma categoria referenciada
  # por qualquer um dos três batia direto na constraint do banco
  # (ActiveRecord::InvalidForeignKey não tratada), não no erro de validação
  # amigável que Despesa já tinha.
  it "retorna erro (sem levantar exceção) quando há Compra associada" do
    credor = Credor.create!(nome: "Nubank")
    cartao = Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 1, 1))
    categoria = Categoria.create!(nome: "Mercado")
    CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 1, 1), valor_total: 100, parcelado: false, categoria_id: categoria.id)

    resultado = ExcluirCategoria.call(categoria: categoria)

    expect(resultado).to be_erro
    expect(Categoria.exists?(categoria.id)).to be true
  end

  it "retorna erro (sem levantar exceção) quando há Parcelamento associado" do
    categoria = Categoria.create!(nome: "Mercado")
    CriarParcelamento.call(valor_total: 300, numero_parcelas: 3, data: Date.current, categoria_id: categoria.id, tipo: "variavel", forma_pagamento: "boleto")

    resultado = ExcluirCategoria.call(categoria: categoria)

    expect(resultado).to be_erro
    expect(Categoria.exists?(categoria.id)).to be true
  end

  it "retorna erro (sem levantar exceção) quando há Emprestimo associado" do
    credor = Credor.create!(nome: "Nubank")
    categoria = Categoria.create!(nome: "Financiamento")
    CriarEmprestimo.call(nome: "Financiamento do carro", credor_id: credor.id, categoria_id: categoria.id, valor_total: 300, cronograma_texto: "2026-08-15,300.00")

    resultado = ExcluirCategoria.call(categoria: categoria)

    expect(resultado).to be_erro
    expect(Categoria.exists?(categoria.id)).to be true
  end
end
