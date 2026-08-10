require "rails_helper"

RSpec.describe ExcluirRenda do
  it "remove a renda e retorna sucesso" do
    renda = Renda.create!(valor: 100, data: Date.current, fonte: "Venda avulsa")

    resultado = ExcluirRenda.call(renda: renda)

    expect(resultado).to be_sucesso
    expect(Renda.exists?(renda.id)).to be false
  end
end
