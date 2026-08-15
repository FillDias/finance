require "rails_helper"

RSpec.describe CriarParcelamento do
  let(:categoria) { Categoria.create!(nome: "Mercado") }

  it "cria o parcelamento com N parcelas geradas automaticamente" do
    resultado = CriarParcelamento.call(
      valor_total: 1749, numero_parcelas: 5, data: Date.new(2026, 7, 10),
      categoria_id: categoria.id, tipo: "variavel", forma_pagamento: "boleto"
    )

    expect(resultado).to be_sucesso
    parcelamento = resultado.valor
    expect(parcelamento).to be_persisted
    expect(parcelamento.parcelas.count).to eq(5)
    expect(parcelamento.parcelas.order(:data_vencimento).pluck(:valor)).to eq([
      349.80.to_d, 349.80.to_d, 349.80.to_d, 349.80.to_d, 349.80.to_d
    ])
  end

  it "cada parcela vence no mesmo dia do mês da data original, um mês depois da anterior" do
    resultado = CriarParcelamento.call(
      valor_total: 300, numero_parcelas: 3, data: Date.new(2026, 7, 10),
      categoria_id: categoria.id, tipo: "variavel", forma_pagamento: "boleto"
    )

    expect(resultado.valor.parcelas.order(:data_vencimento).pluck(:data_vencimento)).to eq([
      Date.new(2026, 7, 10), Date.new(2026, 8, 10), Date.new(2026, 9, 10)
    ])
  end

  it "rejeita e não persiste nada quando o parcelamento é inválido" do
    resultado = CriarParcelamento.call(
      valor_total: 300, numero_parcelas: 1, data: Date.new(2026, 7, 10),
      categoria_id: categoria.id, tipo: "variavel", forma_pagamento: "boleto"
    )

    expect(resultado).to be_erro
    expect(Parcelamento.count).to eq(0)
    expect(Parcela.count).to eq(0)
  end
end
