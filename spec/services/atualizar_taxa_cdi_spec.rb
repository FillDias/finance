require "rails_helper"

RSpec.describe AtualizarTaxaCdi do
  it "atualiza o valor da taxa CDI, criando o registro se ainda não existir" do
    resultado = AtualizarTaxaCdi.call(valor: 10.75)

    expect(resultado).to be_sucesso
    expect(TaxaCdi.atual.valor).to eq(10.75.to_d)
    expect(TaxaCdi.count).to eq(1)
  end

  it "atualiza o mesmo registro em chamadas seguintes, sem duplicar" do
    AtualizarTaxaCdi.call(valor: 10.75)
    resultado = AtualizarTaxaCdi.call(valor: 11.25)

    expect(resultado).to be_sucesso
    expect(TaxaCdi.atual.valor).to eq(11.25.to_d)
    expect(TaxaCdi.count).to eq(1)
  end

  it "retorna erro e não altera o valor quando o dado é inválido" do
    AtualizarTaxaCdi.call(valor: 10.75)

    resultado = AtualizarTaxaCdi.call(valor: -1)

    expect(resultado).to be_erro
    expect(TaxaCdi.atual.valor).to eq(10.75.to_d)
  end
end
