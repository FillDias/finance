require "rails_helper"

RSpec.describe DespesasFiltradas do
  let(:alimentacao) { Categoria.create!(nome: "Alimentação") }
  let(:transporte) { Categoria.create!(nome: "Transporte") }

  before do
    Despesa.create!(valor: 50, data: Date.new(2026, 1, 10), categoria: alimentacao, tipo: :variavel, forma_pagamento: :dinheiro)
    Despesa.create!(valor: 30, data: Date.new(2026, 2, 5), categoria: transporte, tipo: :variavel, forma_pagamento: :pix)
    Despesa.create!(valor: 120, data: Date.new(2026, 3, 1), categoria: alimentacao, tipo: :fixa, forma_pagamento: :boleto, dia_vencimento: 1)
  end

  it "retorna todas as despesas quando nenhum filtro é passado" do
    expect(DespesasFiltradas.call.size).to eq(3)
  end

  it "filtra por categoria" do
    resultado = DespesasFiltradas.call(categoria_id: alimentacao.id)

    expect(resultado.size).to eq(2)
    expect(resultado).to all(have_attributes(categoria_id: alimentacao.id))
  end

  it "filtra por período" do
    resultado = DespesasFiltradas.call(periodo: Date.new(2026, 1, 1)..Date.new(2026, 2, 28))

    expect(resultado.size).to eq(2)
  end

  it "combina filtro de categoria e período" do
    resultado = DespesasFiltradas.call(categoria_id: alimentacao.id, periodo: Date.new(2026, 3, 1)..Date.new(2026, 3, 31))

    expect(resultado.size).to eq(1)
    expect(resultado.first.data).to eq(Date.new(2026, 3, 1))
  end

  it "ordena por data decrescente" do
    resultado = DespesasFiltradas.call

    expect(resultado.map(&:data)).to eq(resultado.map(&:data).sort.reverse)
  end
end
