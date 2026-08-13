require "rails_helper"

RSpec.describe CentralDeObrigacoesQuery do
  let(:credor) { Credor.create!(nome: "Nubank") }
  let(:cartao) { Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 1, 1)) }
  let(:categoria) { Categoria.create!(nome: "Alimentação") }

  describe "Saldo Herdado" do
    it "sem variação enquanto não foi pago" do
      SaldoHerdado.create!(cartao: cartao, mes_referencia: Date.current.beginning_of_month, valor_total: 800)

      linha = CentralDeObrigacoesQuery.call.find { |l| l.origem == "Saldo Herdado" }

      expect(linha.previsto).to eq(800.to_d)
      expect(linha.pago).to be_nil
      expect(linha.variacao).to be_nil
    end

    it "com variação positiva quando pago a menos do que o previsto" do
      saldo = SaldoHerdado.create!(cartao: cartao, mes_referencia: Date.current.beginning_of_month, valor_total: 800)
      QuitarSaldoHerdado.call(saldo_herdado: saldo, valor_pago: 700, data_pagamento: Date.current)

      linha = CentralDeObrigacoesQuery.call.find { |l| l.origem == "Saldo Herdado" }

      expect(linha).to be_paga
      expect(linha.variacao).to eq(-100.to_d)
    end
  end

  describe "Parcela de Compra" do
    it "pago é igual ao valor previsto quando a parcela está paga" do
      resultado = CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.current.beginning_of_month, valor_total: 300, parcelado: false)
      resultado.valor.parcelas.first.update!(status: :paga)

      linha = CentralDeObrigacoesQuery.call.find { |l| l.origem == "Parcela de Compra" }

      expect(linha.variacao).to eq(0.to_d)
    end

    it "sem variação enquanto pendente" do
      CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.current.beginning_of_month, valor_total: 300, parcelado: false)

      linha = CentralDeObrigacoesQuery.call.find { |l| l.origem == "Parcela de Compra" }

      expect(linha.variacao).to be_nil
      expect(linha).not_to be_paga
    end
  end

  describe "Despesa Fixa" do
    it "previsto e pago são o mesmo valor, sem variação" do
      Despesa.create!(valor: 120, data: Date.current, categoria: categoria, tipo: :fixa, forma_pagamento: :boleto, dia_vencimento: 10)

      linha = CentralDeObrigacoesQuery.call.find { |l| l.origem == "Despesa Fixa" }

      expect(linha.previsto).to eq(120.to_d)
      expect(linha.pago).to eq(120.to_d)
      expect(linha.variacao).to eq(0.to_d)
      expect(linha).to be_paga
    end
  end

  it "ordena por vencimento" do
    SaldoHerdado.create!(cartao: cartao, mes_referencia: Date.current.beginning_of_month, valor_total: 800)
    Despesa.create!(valor: 50, data: Date.current.beginning_of_month, categoria: categoria, tipo: :fixa, forma_pagamento: :boleto, dia_vencimento: 1)

    linhas = CentralDeObrigacoesQuery.call

    expect(linhas.map(&:vencimento)).to eq(linhas.map(&:vencimento).sort)
  end
end
