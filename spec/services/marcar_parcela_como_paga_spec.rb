require "rails_helper"

RSpec.describe MarcarParcelaComoPaga do
  let(:credor) { Credor.create!(nome: "Caixa") }
  let(:emprestimo) { Emprestimo.create!(nome: "Financiamento do carro", credor: credor, valor_total: 30000) }
  let(:parcela) { emprestimo.parcelas.create!(valor: 450, data_vencimento: Date.new(2026, 8, 15), status: :pendente) }

  it "marca a parcela como paga com a data informada" do
    resultado = MarcarParcelaComoPaga.call(parcela: parcela, data_pagamento: Date.new(2026, 8, 10))

    expect(resultado).to be_sucesso
    expect(parcela.reload.paga?).to be true
    expect(parcela.data_pagamento).to eq(Date.new(2026, 8, 10))
  end

  it "usa a data de hoje por padrão quando nenhuma data é informada" do
    resultado = MarcarParcelaComoPaga.call(parcela: parcela)

    expect(resultado).to be_sucesso
    expect(parcela.reload.data_pagamento).to eq(Date.current)
  end

  it "deixa de estar atrasada depois de marcada como paga, mesmo com vencimento no passado" do
    parcela_vencida = emprestimo.parcelas.create!(valor: 450, data_vencimento: Date.current - 5, status: :pendente)
    expect(parcela_vencida.atrasada?).to be true

    MarcarParcelaComoPaga.call(parcela: parcela_vencida)

    expect(parcela_vencida.reload.atrasada?).to be false
  end
end
