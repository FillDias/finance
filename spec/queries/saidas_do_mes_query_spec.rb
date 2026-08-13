require "rails_helper"

RSpec.describe SaidasDoMesQuery do
  let(:categoria) { Categoria.create!(nome: "Mercado") }
  let(:credor) { Credor.create!(nome: "Nubank") }
  let(:cartao) { Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 1, 1)) }

  it "soma despesas do mês" do
    Despesa.create!(valor: 200, data: Date.new(2026, 3, 5), categoria: categoria, tipo: :variavel, forma_pagamento: :dinheiro)
    Despesa.create!(valor: 100, data: Date.new(2026, 4, 1), categoria: categoria, tipo: :variavel, forma_pagamento: :dinheiro)

    expect(SaidasDoMesQuery.call(mes: Date.new(2026, 3, 15))).to eq(200.to_d)
  end

  it "inclui compras categorizadas (despesa paga no cartão) do mês" do
    CriarDespesa.call(
      valor: 150, data: Date.new(2026, 3, 10), categoria_id: categoria.id, tipo: "variavel",
      forma_pagamento: "cartao", cartao_id: cartao.id, parcelado: false
    )

    expect(SaidasDoMesQuery.call(mes: Date.new(2026, 3, 1))).to eq(150.to_d)
  end

  it "não inclui compras sem categoria (lançadas direto no cartão, fora do fluxo de Despesa)" do
    CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 3, 10), valor_total: 900, parcelado: false)

    expect(SaidasDoMesQuery.call(mes: Date.new(2026, 3, 1))).to eq(0)
  end

  it "retorna zero quando não há despesas no mês" do
    expect(SaidasDoMesQuery.call(mes: Date.new(2026, 3, 1))).to eq(0)
  end

  it "filtra por categoria" do
    outra_categoria = Categoria.create!(nome: "Lazer")
    Despesa.create!(valor: 200, data: Date.new(2026, 3, 5), categoria: categoria, tipo: :variavel, forma_pagamento: :dinheiro)
    Despesa.create!(valor: 90, data: Date.new(2026, 3, 6), categoria: outra_categoria, tipo: :variavel, forma_pagamento: :pix)

    expect(SaidasDoMesQuery.call(mes: Date.new(2026, 3, 1), categoria_id: categoria.id)).to eq(200.to_d)
  end

  it "filtra por cartão, restringindo a Compra e excluindo Despesa" do
    Despesa.create!(valor: 200, data: Date.new(2026, 3, 5), categoria: categoria, tipo: :variavel, forma_pagamento: :dinheiro)
    CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 3, 5), valor_total: 300, parcelado: false, categoria_id: categoria.id)

    expect(SaidasDoMesQuery.call(mes: Date.new(2026, 3, 1), cartao_id: cartao.id)).to eq(300.to_d)
  end
end
