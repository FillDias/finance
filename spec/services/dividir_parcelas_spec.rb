require "rails_helper"

RSpec.describe DividirParcelas do
  it "divide R$1000 em 3x, com o ajuste de centavos na última parcela" do
    resultado = DividirParcelas.call(
      valor_total: 1000, numero_parcelas: 3, mes_base: Date.new(2026, 8, 1), dia_vencimento: 12
    )

    valores = resultado.valor.map { |p| p[:valor] }

    expect(valores).to eq([ 333.33.to_d, 333.33.to_d, 333.34.to_d ])
    expect(valores.sum).to eq(1000.to_d)
  end

  it "uma única parcela com o valor total" do
    resultado = DividirParcelas.call(
      valor_total: 250, numero_parcelas: 1, mes_base: Date.new(2026, 7, 1), dia_vencimento: 12
    )

    expect(resultado.valor.size).to eq(1)
    expect(resultado.valor.first[:valor]).to eq(250.to_d)
  end

  it "divide um valor exato sem sobra" do
    resultado = DividirParcelas.call(
      valor_total: 300, numero_parcelas: 3, mes_base: Date.new(2026, 7, 1), dia_vencimento: 12
    )

    expect(resultado.valor.map { |p| p[:valor] }).to eq([ 100.to_d, 100.to_d, 100.to_d ])
  end

  it "primeira parcela vence no mês-base recebido, sem aplicar corte nenhum" do
    resultado = DividirParcelas.call(
      valor_total: 100, numero_parcelas: 1, mes_base: Date.new(2026, 7, 1), dia_vencimento: 12
    )

    expect(resultado.valor.first[:data_vencimento]).to eq(Date.new(2026, 7, 12))
  end

  it "parcelas seguintes incrementam um mês a partir do mês-base" do
    resultado = DividirParcelas.call(
      valor_total: 300, numero_parcelas: 3, mes_base: Date.new(2026, 8, 1), dia_vencimento: 12
    )

    expect(resultado.valor.map { |p| p[:data_vencimento] }).to eq([
      Date.new(2026, 8, 12), Date.new(2026, 9, 12), Date.new(2026, 10, 12)
    ])
  end

  it "usa o último dia do mês quando o dia de vencimento não existe naquele mês" do
    resultado = DividirParcelas.call(
      valor_total: 100, numero_parcelas: 1, mes_base: Date.new(2026, 1, 1), dia_vencimento: 31
    )

    expect(resultado.valor.first[:data_vencimento]).to eq(Date.new(2026, 1, 31))

    resultado_fevereiro = DividirParcelas.call(
      valor_total: 100, numero_parcelas: 1, mes_base: Date.new(2026, 2, 1), dia_vencimento: 31
    )

    expect(resultado_fevereiro.valor.first[:data_vencimento]).to eq(Date.new(2026, 2, 28))
  end
end
