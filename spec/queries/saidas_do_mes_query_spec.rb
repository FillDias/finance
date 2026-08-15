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

  it "inclui compras categorizadas (despesa paga no cartão), pela parcela que vence no mês" do
    CriarDespesa.call(
      valor: 150, data: Date.new(2026, 3, 3), categoria_id: categoria.id, tipo: "variavel",
      forma_pagamento: "cartao", cartao_id: cartao.id, parcelado: false
    )

    expect(SaidasDoMesQuery.call(mes: Date.new(2026, 3, 1))).to eq(150.to_d)
  end

  it "não inclui compras sem categoria (lançadas direto no cartão, fora do fluxo de Despesa)" do
    CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 3, 3), valor_total: 900, parcelado: false)

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
    CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 3, 3), valor_total: 300, parcelado: false, categoria_id: categoria.id)

    expect(SaidasDoMesQuery.call(mes: Date.new(2026, 3, 1), cartao_id: cartao.id)).to eq(300.to_d)
  end

  describe "compra parcelada — regressão do bug que somava o valor total, não a parcela do mês" do
    it "cada mês soma só a parcela que vence naquele mês, nunca o valor total da compra" do
      CriarCompraNoCartao.call(
        cartao_id: cartao.id, data_compra: Date.new(2026, 7, 20), valor_total: 1749.00, parcelado: true,
        numero_parcelas: 5, categoria_id: categoria.id
      )
      # dia_fechamento 5: compra em 20/07 (>= 5) cai na fatura de agosto;
      # 5 parcelas de R$349,80 vencendo em 12/ago a 12/dez.

      expect(SaidasDoMesQuery.call(mes: Date.new(2026, 7, 1))).to eq(0)
      expect(SaidasDoMesQuery.call(mes: Date.new(2026, 8, 1))).to eq(349.80.to_d)
      expect(SaidasDoMesQuery.call(mes: Date.new(2026, 9, 1))).to eq(349.80.to_d)
      expect(SaidasDoMesQuery.call(mes: Date.new(2026, 12, 1))).to eq(349.80.to_d)
      expect(SaidasDoMesQuery.call(mes: Date.new(2027, 1, 1))).to eq(0)
    end
  end

  describe "Parcelamento (despesa parcelada fora do cartão)" do
    it "conta pela parcela que vence no mês" do
      CriarParcelamento.call(
        valor_total: 300, numero_parcelas: 3, data: Date.new(2026, 3, 10),
        categoria_id: categoria.id, tipo: "variavel", forma_pagamento: "boleto"
      )

      expect(SaidasDoMesQuery.call(mes: Date.new(2026, 3, 1))).to eq(100.to_d)
      expect(SaidasDoMesQuery.call(mes: Date.new(2026, 4, 1))).to eq(100.to_d)
    end

    it "não entra quando o filtro é por cartão" do
      CriarParcelamento.call(
        valor_total: 300, numero_parcelas: 3, data: Date.new(2026, 3, 10),
        categoria_id: categoria.id, tipo: "variavel", forma_pagamento: "boleto"
      )

      expect(SaidasDoMesQuery.call(mes: Date.new(2026, 3, 1), cartao_id: cartao.id)).to eq(0)
    end
  end

  describe "Emprestimo" do
    it "conta pela parcela que vence no mês — dinheiro real saindo, não só uma Obrigação em aberto" do
      CriarEmprestimo.call(
        nome: "Financiamento", credor_id: credor.id, categoria_id: categoria.id, valor_total: 900,
        cronograma_texto: "2026-03-15,300.00\n2026-04-15,300.00\n2026-05-15,300.00"
      )

      expect(SaidasDoMesQuery.call(mes: Date.new(2026, 3, 1))).to eq(300.to_d)
      expect(SaidasDoMesQuery.call(mes: Date.new(2026, 4, 1))).to eq(300.to_d)
    end

    it "conta pelo vencimento, não pelo status pago/pendente" do
      resultado = CriarEmprestimo.call(
        nome: "Financiamento", credor_id: credor.id, categoria_id: categoria.id, valor_total: 300,
        cronograma_texto: "2026-03-15,300.00"
      )
      MarcarParcelaComoPaga.call(parcela: resultado.valor.parcelas.first)

      expect(SaidasDoMesQuery.call(mes: Date.new(2026, 3, 1))).to eq(300.to_d)
    end

    it "não entra quando o filtro é por cartão" do
      CriarEmprestimo.call(
        nome: "Financiamento", credor_id: credor.id, categoria_id: categoria.id, valor_total: 300,
        cronograma_texto: "2026-03-15,300.00"
      )

      expect(SaidasDoMesQuery.call(mes: Date.new(2026, 3, 1), cartao_id: cartao.id)).to eq(0)
    end
  end
end
