require "rails_helper"

RSpec.describe GastoPorCategoriaQuery do
  let(:mercado) { Categoria.create!(nome: "Mercado") }
  let(:lazer) { Categoria.create!(nome: "Lazer") }
  let(:credor) { Credor.create!(nome: "Nubank") }
  let(:cartao) { Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 1, 1)) }

  it "soma Despesa e Compra-com-categoria por categoria, do maior pro menor" do
    Despesa.create!(valor: 200, data: Date.new(2026, 6, 10), categoria: mercado, tipo: :variavel, forma_pagamento: :dinheiro)
    CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 6, 3), valor_total: 400, parcelado: false, categoria_id: mercado.id)
    Despesa.create!(valor: 100, data: Date.new(2026, 6, 10), categoria: lazer, tipo: :variavel, forma_pagamento: :pix)

    itens = GastoPorCategoriaQuery.call(mes: Date.new(2026, 6, 1))

    expect(itens).to eq([
      { categoria_id: mercado.id, categoria: "Mercado", valor: 600.to_d, despesas: 200.to_d, compras: 400.to_d,
        compras_qtd: 1, parcelamentos: 0, emprestimos: 0 },
      { categoria_id: lazer.id, categoria: "Lazer", valor: 100.to_d, despesas: 100.to_d, compras: 0.to_d,
        compras_qtd: 0, parcelamentos: 0, emprestimos: 0 }
    ])
  end

  it "ignora compra sem categoria" do
    CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 6, 3), valor_total: 400, parcelado: false)

    expect(GastoPorCategoriaQuery.call(mes: Date.new(2026, 6, 1))).to be_empty
  end

  it "ignora gasto fora do mês pedido" do
    Despesa.create!(valor: 200, data: Date.new(2026, 4, 10), categoria: mercado, tipo: :variavel, forma_pagamento: :dinheiro)

    expect(GastoPorCategoriaQuery.call(mes: Date.new(2026, 6, 1))).to be_empty
  end

  it "filtra por categoria" do
    Despesa.create!(valor: 200, data: Date.new(2026, 6, 10), categoria: mercado, tipo: :variavel, forma_pagamento: :dinheiro)
    Despesa.create!(valor: 100, data: Date.new(2026, 6, 10), categoria: lazer, tipo: :variavel, forma_pagamento: :pix)

    itens = GastoPorCategoriaQuery.call(mes: Date.new(2026, 6, 1), categoria_id: mercado.id)

    expect(itens.map { |item| item[:categoria] }).to eq([ "Mercado" ])
  end

  it "filtra por cartão, restringindo a Compra e excluindo Despesa" do
    Despesa.create!(valor: 200, data: Date.new(2026, 6, 10), categoria: mercado, tipo: :variavel, forma_pagamento: :dinheiro)
    CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 6, 3), valor_total: 400, parcelado: false, categoria_id: mercado.id)

    itens = GastoPorCategoriaQuery.call(mes: Date.new(2026, 6, 1), cartao_id: cartao.id)

    expect(itens).to eq([
      { categoria_id: mercado.id, categoria: "Mercado", valor: 400.to_d, despesas: 0, compras: 400.to_d,
        compras_qtd: 1, parcelamentos: 0, emprestimos: 0 }
    ])
  end

  describe "compra parcelada — regressão do bug que somava o valor total, não a parcela do mês" do
    it "cada mês soma só a parcela que vence naquele mês, nunca o valor total da compra" do
      CriarCompraNoCartao.call(
        cartao_id: cartao.id, data_compra: Date.new(2026, 7, 20), valor_total: 1749.00, parcelado: true,
        numero_parcelas: 5, categoria_id: mercado.id
      )

      item_agosto = GastoPorCategoriaQuery.call(mes: Date.new(2026, 8, 1)).first

      expect(item_agosto[:valor]).to eq(349.80.to_d)
      expect(item_agosto[:compras]).to eq(349.80.to_d)
      expect(GastoPorCategoriaQuery.call(mes: Date.new(2026, 7, 1))).to be_empty
    end
  end

  describe "Parcelamento" do
    it "conta pela parcela que vence no mês, separado de Despesas/Compras" do
      CriarParcelamento.call(
        valor_total: 300, numero_parcelas: 3, data: Date.new(2026, 6, 10),
        categoria_id: mercado.id, tipo: "variavel", forma_pagamento: "boleto"
      )

      item = GastoPorCategoriaQuery.call(mes: Date.new(2026, 6, 1)).first

      expect(item[:parcelamentos]).to eq(100.to_d)
      expect(item[:valor]).to eq(100.to_d)
    end
  end

  describe "Emprestimo" do
    it "conta pela parcela que vence no mês, separado de Despesas/Compras" do
      CriarEmprestimo.call(
        nome: "Financiamento", credor_id: credor.id, categoria_id: mercado.id, valor_total: 300,
        cronograma_texto: "2026-06-15,300.00"
      )

      item = GastoPorCategoriaQuery.call(mes: Date.new(2026, 6, 1)).first

      expect(item[:emprestimos]).to eq(300.to_d)
      expect(item[:valor]).to eq(300.to_d)
    end
  end
end
