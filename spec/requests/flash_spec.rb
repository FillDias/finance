require "rails_helper"

RSpec.describe "Mensagens de flash", type: :request do
  # Regressão: o layout nunca renderizava flash.notice/flash.alert em lugar
  # nenhum — qualquer redirect com erro (ex.: CriarCompraNoCartao rejeitando
  # uma Despesa no cartão por causa da data de corte) ficava sem nenhum
  # feedback visível, dando a impressão de que o lançamento "sumiu".
  it "mostra o alert quando um redirect falha" do
    categoria = Categoria.create!(nome: "Mercado")
    credor = Credor.create!(nome: "Nubank")
    cartao = Cartao.create!(
      nome: "Ultravioleta", credor: credor, limite_total: 5000,
      dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.current
    )

    post despesas_path, params: {
      despesa: {
        valor: 100, data: Date.current - 5, categoria_id: categoria.id,
        tipo: "variavel", forma_pagamento: "cartao", cartao_id: cartao.id, parcelado: false
      }
    }
    follow_redirect!

    expect(response.body).to include("flash-alert")
    expect(response.body).to include("Compra deve ser feita a partir da data de corte do cartão")
    expect(Despesa.count).to eq(0)
    expect(Compra.count).to eq(0)
  end

  it "mostra o notice quando um redirect é bem-sucedido" do
    categoria = Categoria.create!(nome: "Mercado")

    post despesas_path, params: {
      despesa: { valor: 50, data: Date.current, categoria_id: categoria.id, tipo: "variavel", forma_pagamento: "dinheiro" }
    }
    follow_redirect!

    expect(response.body).to include("flash-notice")
    expect(response.body).to include("Despesa registrada.")
  end
end
