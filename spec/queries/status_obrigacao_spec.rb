require "rails_helper"

RSpec.describe StatusObrigacao do
  it "é paga quando pago é true, independente do vencimento" do
    expect(StatusObrigacao.para(pago: true, vencimento: Date.current - 10)).to eq(:paga)
  end

  it "é atrasada quando não paga e o vencimento já passou" do
    expect(StatusObrigacao.para(pago: false, vencimento: Date.current - 1)).to eq(:atrasada)
  end

  it "é pendente quando não paga e o vencimento ainda não chegou" do
    expect(StatusObrigacao.para(pago: false, vencimento: Date.current + 1)).to eq(:pendente)
  end
end
