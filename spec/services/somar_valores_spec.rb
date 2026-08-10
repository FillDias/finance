require "rails_helper"

RSpec.describe SomarValores do
  it "retorna sucesso com a soma quando os valores são numéricos" do
    resultado = SomarValores.call(2, 3)

    expect(resultado).to be_sucesso
    expect(resultado.valor).to eq(5)
  end

  it "retorna erro quando algum valor não é numérico" do
    resultado = SomarValores.call(2, "x")

    expect(resultado).to be_erro
    expect(resultado.erros).to include("a e b devem ser numéricos")
  end
end
