require "rails_helper"

RSpec.describe Parcela, type: :model do
  let(:credor) { Credor.create!(nome: "Nubank") }
  let(:cartao) { Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 6, 1)) }
  let(:compra) { Compra.create!(cartao: cartao, data_compra: Date.new(2026, 7, 1), valor_total: 300, parcelado: true, numero_parcelas: 3) }

  it "é válida com origem, valor e data de vencimento" do
    parcela = Parcela.new(origem: compra, valor: 100, data_vencimento: Date.new(2026, 8, 12), status: :pendente)

    expect(parcela).to be_valid
  end

  it "é inválida sem valor" do
    parcela = Parcela.new(origem: compra, valor: nil, data_vencimento: Date.current)

    expect(parcela).not_to be_valid
  end

  it "é inválida com valor zero ou negativo" do
    parcela = Parcela.new(origem: compra, valor: 0, data_vencimento: Date.current)

    expect(parcela).not_to be_valid
  end

  it "é inválida sem data de vencimento" do
    parcela = Parcela.new(origem: compra, valor: 100, data_vencimento: nil)

    expect(parcela).not_to be_valid
  end

  it "começa pendente por padrão" do
    parcela = Parcela.create!(origem: compra, valor: 100, data_vencimento: Date.current + 10)

    expect(parcela.pendente?).to be true
  end

  describe "#atrasada?" do
    it "é verdadeira quando pendente e vencida" do
      parcela = Parcela.new(status: :pendente, data_vencimento: Date.current - 1)

      expect(parcela.atrasada?).to be true
    end

    it "é falsa quando pendente mas ainda não vencida" do
      parcela = Parcela.new(status: :pendente, data_vencimento: Date.current + 1)

      expect(parcela.atrasada?).to be false
    end

    it "é falsa quando já paga, mesmo vencida" do
      parcela = Parcela.new(status: :paga, data_vencimento: Date.current - 1)

      expect(parcela.atrasada?).to be false
    end
  end

  describe "#status_label" do
    it "mostra Atrasada quando vencida e pendente, mesmo com status pendente" do
      parcela = Parcela.new(status: :pendente, data_vencimento: Date.current - 1)

      expect(parcela.status_label).to eq("Atrasada")
    end

    it "mostra Pendente quando não vencida" do
      parcela = Parcela.new(status: :pendente, data_vencimento: Date.current + 1)

      expect(parcela.status_label).to eq("Pendente")
    end

    it "mostra Paga quando quitada" do
      parcela = Parcela.new(status: :paga, data_vencimento: Date.current - 1)

      expect(parcela.status_label).to eq("Paga")
    end
  end
end
