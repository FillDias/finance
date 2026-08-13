require "rails_helper"

RSpec.describe GastoPorCategoriaQuery do
  let(:mercado) { Categoria.create!(nome: "Mercado") }
  let(:lazer) { Categoria.create!(nome: "Lazer") }
  let(:credor) { Credor.create!(nome: "Nubank") }
  let(:cartao) { Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 1, 1)) }

  it "soma Despesa e Compra-com-categoria por categoria, do maior pro menor" do
    Despesa.create!(valor: 200, data: Date.current, categoria: mercado, tipo: :variavel, forma_pagamento: :dinheiro)
    CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.current, valor_total: 400, parcelado: false, categoria_id: mercado.id)
    Despesa.create!(valor: 100, data: Date.current, categoria: lazer, tipo: :variavel, forma_pagamento: :pix)

    itens = GastoPorCategoriaQuery.call(mes: Date.current)

    expect(itens).to eq([
      { categoria_id: mercado.id, categoria: "Mercado", valor: 600.to_d, despesas: 200.to_d, compras: 400.to_d, compras_qtd: 1 },
      { categoria_id: lazer.id, categoria: "Lazer", valor: 100.to_d, despesas: 100.to_d, compras: 0.to_d, compras_qtd: 0 }
    ])
  end

  it "ignora compra sem categoria" do
    CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.current, valor_total: 400, parcelado: false)

    expect(GastoPorCategoriaQuery.call(mes: Date.current)).to be_empty
  end

  it "ignora gasto fora do mês pedido" do
    Despesa.create!(valor: 200, data: Date.current - 2.months, categoria: mercado, tipo: :variavel, forma_pagamento: :dinheiro)

    expect(GastoPorCategoriaQuery.call(mes: Date.current)).to be_empty
  end
end
