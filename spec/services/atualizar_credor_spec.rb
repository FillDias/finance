require "rails_helper"

RSpec.describe AtualizarCredor do
  it "atualiza o nome e retorna sucesso" do
    credor = Credor.create!(nome: "Nubank")

    resultado = AtualizarCredor.call(credor: credor, nome: "Nu Pagamentos")

    expect(resultado).to be_sucesso
    expect(credor.reload.nome).to eq("Nu Pagamentos")
  end

  it "retorna erro quando o novo nome já existe em outro credor" do
    Credor.create!(nome: "Santander")
    credor = Credor.create!(nome: "Nubank")

    resultado = AtualizarCredor.call(credor: credor, nome: "Santander")

    expect(resultado).to be_erro
    expect(credor.reload.nome).to eq("Nubank")
  end
end
