require "rails_helper"

RSpec.describe AtualizarTipoInvestimento do
  it "atualiza o nome e retorna sucesso" do
    tipo = TipoInvestimento.create!(nome: "Cripto")

    resultado = AtualizarTipoInvestimento.call(tipo_investimento: tipo, nome: "Criptoativos")

    expect(resultado).to be_sucesso
    expect(tipo.reload.nome).to eq("Criptoativos")
  end

  it "retorna erro quando o novo nome já existe em outro tipo" do
    TipoInvestimento.create!(nome: "CDB")
    tipo = TipoInvestimento.create!(nome: "Cripto")

    resultado = AtualizarTipoInvestimento.call(tipo_investimento: tipo, nome: "CDB")

    expect(resultado).to be_erro
    expect(tipo.reload.nome).to eq("Cripto")
  end
end
