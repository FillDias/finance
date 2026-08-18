require "rails_helper"

RSpec.describe GerarParcelas do
  it "divide o valor e monta as datas delegando pra DividirParcelas" do
    resultado = GerarParcelas.call(
      valor_total: 1000, numero_parcelas: 3, data_compra: Date.new(2026, 7, 1),
      dia_fechamento: 5, dia_vencimento: 12
    )

    valores = resultado.valor.map { |p| p[:valor] }

    expect(valores).to eq([ 333.33.to_d, 333.33.to_d, 333.34.to_d ])
    expect(valores.sum).to eq(1000.to_d)
  end

  it "compra à vista gera uma única parcela com o valor total" do
    resultado = GerarParcelas.call(
      valor_total: 250, numero_parcelas: 1, data_compra: Date.new(2026, 7, 10),
      dia_fechamento: 5, dia_vencimento: 12
    )

    expect(resultado.valor.size).to eq(1)
    expect(resultado.valor.first[:valor]).to eq(250.to_d)
  end

  describe "regra de fechamento" do
    it "compra antes do dia de fechamento cai na fatura do mesmo mês" do
      resultado = GerarParcelas.call(
        valor_total: 100, numero_parcelas: 1, data_compra: Date.new(2026, 7, 4),
        dia_fechamento: 5, dia_vencimento: 12
      )

      expect(resultado.valor.first[:data_vencimento]).to eq(Date.new(2026, 7, 12))
    end

    it "compra exatamente no dia de fechamento já cai na fatura do mês seguinte" do
      resultado = GerarParcelas.call(
        valor_total: 100, numero_parcelas: 1, data_compra: Date.new(2026, 7, 5),
        dia_fechamento: 5, dia_vencimento: 12
      )

      expect(resultado.valor.first[:data_vencimento]).to eq(Date.new(2026, 8, 12))
    end

    it "compra depois do dia de fechamento cai na fatura do mês seguinte" do
      resultado = GerarParcelas.call(
        valor_total: 100, numero_parcelas: 1, data_compra: Date.new(2026, 7, 6),
        dia_fechamento: 5, dia_vencimento: 12
      )

      expect(resultado.valor.first[:data_vencimento]).to eq(Date.new(2026, 8, 12))
    end

    it "parcelas seguintes incrementam um mês a partir da primeira fatura" do
      resultado = GerarParcelas.call(
        valor_total: 300, numero_parcelas: 3, data_compra: Date.new(2026, 7, 6),
        dia_fechamento: 5, dia_vencimento: 12
      )

      expect(resultado.valor.map { |p| p[:data_vencimento] }).to eq([
        Date.new(2026, 8, 12), Date.new(2026, 9, 12), Date.new(2026, 10, 12)
      ])
    end
  end

  # Regressão: a correção anterior só resolvia em qual mês a compra fecha
  # (Etapa 1) — mas quando o dia de vencimento é ANTES do dia de
  # fechamento (o caso mais comum, ex.: fecha dia 29, vence dia 8), o
  # vencimento cai no mês seguinte ao fechamento, não no mesmo mês. Essa
  # segunda etapa nunca tinha teste — a fixture usada em todo o resto
  # deste arquivo (fechamento 5, vencimento 12) só cobre o caso oposto.
  describe "regra de vencimento (Etapa 2: em qual mês o vencimento do fechamento cai)" do
    it "dia_vencimento < dia_fechamento, compra antes do fechamento: Itaú Pão de Açúcar (fecha 29, vence 8), compra em 05/08" do
      resultado = GerarParcelas.call(
        valor_total: 100, numero_parcelas: 1, data_compra: Date.new(2026, 8, 5),
        dia_fechamento: 29, dia_vencimento: 8
      )

      expect(resultado.valor.first[:data_vencimento]).to eq(Date.new(2026, 9, 8))
    end

    it "dia_vencimento < dia_fechamento, compra exatamente no dia de fechamento" do
      resultado = GerarParcelas.call(
        valor_total: 100, numero_parcelas: 1, data_compra: Date.new(2026, 8, 29),
        dia_fechamento: 29, dia_vencimento: 8
      )

      # fecha em setembro (dia 29 >= 29) e o vencimento (8) é antes do
      # fechamento (29), então vence só em outubro.
      expect(resultado.valor.first[:data_vencimento]).to eq(Date.new(2026, 10, 8))
    end

    it "dia_vencimento < dia_fechamento, compra depois do fechamento: Santander Elite (fecha 30, vence 7), compra em 20/08" do
      resultado = GerarParcelas.call(
        valor_total: 100, numero_parcelas: 1, data_compra: Date.new(2026, 8, 20),
        dia_fechamento: 30, dia_vencimento: 7
      )

      expect(resultado.valor.first[:data_vencimento]).to eq(Date.new(2026, 9, 7))
    end

    it "dia_vencimento >= dia_fechamento, compra antes do fechamento: vence no mesmo mês do fechamento" do
      resultado = GerarParcelas.call(
        valor_total: 100, numero_parcelas: 1, data_compra: Date.new(2026, 8, 3),
        dia_fechamento: 5, dia_vencimento: 20
      )

      expect(resultado.valor.first[:data_vencimento]).to eq(Date.new(2026, 8, 20))
    end

    it "dia_vencimento >= dia_fechamento, compra exatamente no dia de fechamento: vence no mesmo mês do fechamento seguinte" do
      resultado = GerarParcelas.call(
        valor_total: 100, numero_parcelas: 1, data_compra: Date.new(2026, 8, 5),
        dia_fechamento: 5, dia_vencimento: 20
      )

      expect(resultado.valor.first[:data_vencimento]).to eq(Date.new(2026, 9, 20))
    end

    it "dia_vencimento >= dia_fechamento, compra depois do fechamento: vence no mesmo mês do fechamento seguinte" do
      resultado = GerarParcelas.call(
        valor_total: 100, numero_parcelas: 1, data_compra: Date.new(2026, 8, 10),
        dia_fechamento: 5, dia_vencimento: 20
      )

      expect(resultado.valor.first[:data_vencimento]).to eq(Date.new(2026, 9, 20))
    end

    it "parcelas seguintes continuam incrementando um mês a partir do primeiro vencimento correto" do
      resultado = GerarParcelas.call(
        valor_total: 300, numero_parcelas: 3, data_compra: Date.new(2026, 8, 5),
        dia_fechamento: 29, dia_vencimento: 8
      )

      expect(resultado.valor.map { |p| p[:data_vencimento] }).to eq([
        Date.new(2026, 9, 8), Date.new(2026, 10, 8), Date.new(2026, 11, 8)
      ])
    end
  end
end
