require "rails_helper"

RSpec.describe CriarRenda do
  it "cria a renda e retorna sucesso quando os dados são válidos" do
    resultado = CriarRenda.call(valor: 1500, data: Date.new(2026, 3, 1), fonte: "Salário")

    expect(resultado).to be_sucesso
    expect(resultado.valor).to be_persisted
    expect(Renda.count).to eq(1)
  end

  it "não cria a renda e retorna erro quando os dados são inválidos" do
    resultado = CriarRenda.call(valor: nil, data: Date.new(2026, 3, 1), fonte: "Salário")

    expect(resultado).to be_erro
    expect(resultado.erros).not_to be_empty
    expect(Renda.count).to eq(0)
  end
end
