require "rails_helper"

RSpec.describe ObrigacoesQuery do
  let(:credor) { Credor.create!(nome: "Nubank") }
  let(:cartao) do
    Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 1, 1))
  end
  let(:categoria) { Categoria.create!(nome: "Alimentação") }

  describe "Saldo Herdado" do
    it "inclui saldo herdado em aberto, com vencimento no dia de vencimento do cartão" do
      SaldoHerdado.create!(cartao: cartao, mes_referencia: Date.new(2026, 7, 1), valor_total: 800)

      itens = ObrigacoesQuery.call

      item = itens.find { |i| i.origem == "Saldo Herdado" }
      expect(item).not_to be_nil
      expect(item.valor).to eq(800.to_d)
      expect(item.vencimento).to eq(Date.new(2026, 7, 12))
    end

    it "não inclui saldo herdado já quitado" do
      saldo = SaldoHerdado.create!(cartao: cartao, mes_referencia: Date.new(2026, 7, 1), valor_total: 800)
      QuitarSaldoHerdado.call(saldo_herdado: saldo, valor_pago: 700, data_pagamento: Date.current)

      expect(ObrigacoesQuery.call).to be_empty
    end

    it "usa o último dia do mês quando o dia de vencimento do cartão não existe naquele mês" do
      cartao_dia_31 = Cartao.create!(nome: "Gold", credor: credor, limite_total: 3000, dia_fechamento: 25, dia_vencimento: 31, data_corte: Date.new(2026, 1, 1))
      SaldoHerdado.create!(cartao: cartao_dia_31, mes_referencia: Date.new(2026, 2, 1), valor_total: 500)

      item = ObrigacoesQuery.call.first

      expect(item.vencimento).to eq(Date.new(2026, 2, 28))
    end
  end

  describe "Parcela de Compra" do
    it "inclui parcelas pendentes de compras" do
      CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 7, 3), valor_total: 300, parcelado: false)

      item = ObrigacoesQuery.call.find { |i| i.origem == "Parcela de Compra" }

      expect(item).not_to be_nil
      expect(item.valor).to eq(300.to_d)
    end

    it "não inclui parcelas de compra já pagas" do
      resultado = CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 7, 3), valor_total: 300, parcelado: false)
      resultado.valor.parcelas.first.update!(status: :paga)

      expect(ObrigacoesQuery.call.map(&:origem)).not_to include("Parcela de Compra")
    end
  end

  describe "Parcela de Empréstimo" do
    it "inclui parcelas pendentes de empréstimo" do
      CriarEmprestimo.call(nome: "Financiamento", credor_id: credor.id, valor_total: 30000, cronograma_texto: "2026-08-15,450.00")

      item = ObrigacoesQuery.call.find { |i| i.origem == "Parcela de Empréstimo" }

      expect(item).not_to be_nil
      expect(item.valor).to eq(450.0.to_d)
      expect(item.vencimento).to eq(Date.new(2026, 8, 15))
    end

    it "não inclui parcelas de empréstimo já pagas" do
      resultado = CriarEmprestimo.call(nome: "Financiamento", credor_id: credor.id, valor_total: 30000, cronograma_texto: "2026-08-15,450.00")
      MarcarParcelaComoPaga.call(parcela: resultado.valor.parcelas.first)

      expect(ObrigacoesQuery.call.map(&:origem)).not_to include("Parcela de Empréstimo")
    end
  end

  describe "Parcela de Parcelamento" do
    it "inclui parcelas pendentes de parcelamento" do
      CriarParcelamento.call(valor_total: 300, numero_parcelas: 3, data: Date.new(2026, 7, 3), categoria_id: categoria.id, tipo: "variavel", forma_pagamento: "boleto")

      item = ObrigacoesQuery.call.find { |i| i.origem == "Parcela de Parcelamento" }

      expect(item).not_to be_nil
      expect(item.valor).to eq(100.to_d)
    end

    it "não inclui parcelas de parcelamento já pagas" do
      resultado = CriarParcelamento.call(valor_total: 300, numero_parcelas: 3, data: Date.new(2026, 7, 3), categoria_id: categoria.id, tipo: "variavel", forma_pagamento: "boleto")
      resultado.valor.parcelas.first.update!(status: :paga)

      expect(ObrigacoesQuery.call.count { |i| i.origem == "Parcela de Parcelamento" }).to eq(2)
    end
  end

  describe "Despesa Fixa" do
    it "inclui despesa fixa, usando a data como vencimento" do
      Despesa.create!(valor: 120, data: Date.current + 5, categoria: categoria, tipo: :fixa, forma_pagamento: :boleto, dia_vencimento: 10)

      item = ObrigacoesQuery.call.find { |i| i.origem == "Despesa Fixa" }

      expect(item).not_to be_nil
      expect(item.valor).to eq(120.to_d)
    end

    it "não inclui despesa variável" do
      Despesa.create!(valor: 50, data: Date.current, categoria: categoria, tipo: :variavel, forma_pagamento: :dinheiro)

      expect(ObrigacoesQuery.call.map(&:origem)).not_to include("Despesa Fixa")
    end

    it "nunca tem status paga, mesmo com vencimento no passado (fica atrasada)" do
      Despesa.create!(valor: 120, data: Date.current - 3, categoria: categoria, tipo: :fixa, forma_pagamento: :boleto, dia_vencimento: 10)

      item = ObrigacoesQuery.call.find { |i| i.origem == "Despesa Fixa" }

      expect(item).to be_atrasada
      expect(item).not_to be_paga
    end
  end

  describe "cálculo de status" do
    it "marca como atrasada uma parcela pendente com vencimento no passado" do
      CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.current - 60, valor_total: 200, parcelado: false)

      item = ObrigacoesQuery.call.find { |i| i.origem == "Parcela de Compra" }

      expect(item).to be_atrasada
    end

    it "marca como pendente uma parcela ainda não vencida" do
      CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.current, valor_total: 200, parcelado: false)

      item = ObrigacoesQuery.call.find { |i| i.origem == "Parcela de Compra" }

      expect(item).to be_pendente
      expect(item).not_to be_atrasada
    end
  end

  describe "Despesa que virou Compra (ticket #9) não duplica" do
    it "aparece só como Parcela de Compra, nunca também como Despesa Fixa" do
      CriarDespesa.call(
        valor: 150, data: Date.new(2026, 7, 3), categoria_id: categoria.id, tipo: "fixa",
        forma_pagamento: "cartao", cartao_id: cartao.id, parcelado: false, dia_vencimento: 10
      )

      itens = ObrigacoesQuery.call

      expect(itens.count { |i| i.valor == 150.to_d }).to eq(1)
      expect(itens.find { |i| i.valor == 150.to_d }.origem).to eq("Parcela de Compra")
    end
  end

  describe "filtro por período" do
    it "filtra por data de início e fim, combinando as quatro origens" do
      SaldoHerdado.create!(cartao: cartao, mes_referencia: Date.new(2026, 3, 1), valor_total: 800)
      CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 7, 3), valor_total: 300, parcelado: false)
      Despesa.create!(valor: 120, data: Date.new(2026, 12, 10), categoria: categoria, tipo: :fixa, forma_pagamento: :boleto, dia_vencimento: 10)

      itens = ObrigacoesQuery.call(data_inicio: Date.new(2026, 7, 1), data_fim: Date.new(2026, 7, 31))

      expect(itens.size).to eq(1)
      expect(itens.first.origem).to eq("Parcela de Compra")
    end
  end

  it "ordena por vencimento crescente" do
    SaldoHerdado.create!(cartao: cartao, mes_referencia: Date.new(2026, 9, 1), valor_total: 800)
    CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 7, 3), valor_total: 300, parcelado: false)

    itens = ObrigacoesQuery.call

    expect(itens.map(&:vencimento)).to eq(itens.map(&:vencimento).sort)
  end
end
