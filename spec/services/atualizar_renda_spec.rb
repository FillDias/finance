require "rails_helper"

RSpec.describe AtualizarRenda do
  it "atualiza a renda e retorna sucesso quando os dados são válidos" do
    renda = Renda.create!(valor: 1000, data: Date.new(2026, 1, 1), fonte: "Freela")

    resultado = AtualizarRenda.call(renda: renda, valor: 2000, data: Date.new(2026, 1, 2), fonte: "Salário")

    expect(resultado).to be_sucesso
    expect(renda.reload.valor).to eq(2000)
    expect(renda.fonte).to eq("Salário")
  end

  it "não atualiza e retorna erro quando os dados são inválidos" do
    renda = Renda.create!(valor: 1000, data: Date.new(2026, 1, 1), fonte: "Freela")

    resultado = AtualizarRenda.call(renda: renda, valor: -5, data: Date.new(2026, 1, 2), fonte: "Salário")

    expect(resultado).to be_erro
    expect(renda.reload.valor).to eq(1000)
  end
end
