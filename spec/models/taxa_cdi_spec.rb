require "rails_helper"

RSpec.describe TaxaCdi, type: :model do
  it "é válida com um valor não negativo" do
    taxa = TaxaCdi.new(valor: 10.75)

    expect(taxa).to be_valid
  end

  it "é inválida sem valor" do
    taxa = TaxaCdi.new(valor: nil)

    expect(taxa).not_to be_valid
  end

  it "é inválida com valor negativo" do
    taxa = TaxaCdi.new(valor: -1)

    expect(taxa).not_to be_valid
  end

  it "é inválida ao tentar criar um segundo registro" do
    TaxaCdi.create!(valor: 10.75)
    segunda = TaxaCdi.new(valor: 11)

    expect(segunda).not_to be_valid
    expect(segunda.errors[:base]).not_to be_empty
  end

  describe ".atual" do
    it "cria o registro único na primeira chamada, com valor zero" do
      expect(TaxaCdi.count).to eq(0)

      taxa = TaxaCdi.atual

      expect(taxa).to be_persisted
      expect(taxa.valor).to eq(0.to_d)
      expect(TaxaCdi.count).to eq(1)
    end

    it "retorna sempre o mesmo registro nas chamadas seguintes" do
      primeira = TaxaCdi.atual
      primeira.update!(valor: 10.75)

      expect(TaxaCdi.atual).to eq(primeira)
      expect(TaxaCdi.atual.valor).to eq(10.75.to_d)
      expect(TaxaCdi.count).to eq(1)
    end
  end
end
