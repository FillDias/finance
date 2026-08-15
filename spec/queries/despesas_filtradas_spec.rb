require "rails_helper"

RSpec.describe DespesasFiltradas do
  let(:alimentacao) { Categoria.create!(nome: "Alimentação") }
  let(:transporte) { Categoria.create!(nome: "Transporte") }
  let(:credor) { Credor.create!(nome: "Nubank") }
  let(:cartao) do
    Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 1, 1))
  end

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
    expect(resultado).to all(have_attributes(categoria_nome: "Alimentação"))
  end

  it "filtra por período" do
    resultado = DespesasFiltradas.call(data_inicio: Date.new(2026, 1, 1), data_fim: Date.new(2026, 2, 28))

    expect(resultado.size).to eq(2)
  end

  it "filtra por período com apenas a data de início" do
    resultado = DespesasFiltradas.call(data_inicio: Date.new(2026, 2, 1))

    expect(resultado.size).to eq(2)
  end

  it "combina filtro de categoria e período" do
    resultado = DespesasFiltradas.call(categoria_id: alimentacao.id, data_inicio: Date.new(2026, 3, 1), data_fim: Date.new(2026, 3, 31))

    expect(resultado.size).to eq(1)
    expect(resultado.first.data).to eq(Date.new(2026, 3, 1))
  end

  it "ordena por data decrescente" do
    resultado = DespesasFiltradas.call

    expect(resultado.map(&:data)).to eq(resultado.map(&:data).sort.reverse)
  end

  describe "Compras pagas no cartão (com categoria)" do
    it "inclui uma Compra com categoria na listagem, marcada como não-despesa" do
      resultado = CriarDespesa.call(
        valor: 200, data: Date.new(2026, 4, 5), categoria_id: transporte.id, tipo: "variavel",
        forma_pagamento: "cartao", cartao_id: cartao.id, parcelado: false
      )
      compra = resultado.valor

      itens = DespesasFiltradas.call
      item_da_compra = itens.find { |item| item.registro == compra }

      expect(item_da_compra).not_to be_nil
      expect(item_da_compra).not_to be_despesa
      expect(item_da_compra.categoria_nome).to eq("Transporte")
      expect(item_da_compra.forma_pagamento_label).to eq("Cartão Ultravioleta")
      expect(item_da_compra.valor).to eq(200.to_d)
    end

    it "não inclui uma Compra sem categoria (lançada direto no cartão, fora do fluxo de Despesa)" do
      CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 4, 5), valor_total: 500, parcelado: false)

      itens = DespesasFiltradas.call

      expect(itens.size).to eq(3)
    end

    it "aparece exatamente uma vez, não duplicada como Despesa também" do
      CriarDespesa.call(
        valor: 200, data: Date.new(2026, 4, 5), categoria_id: transporte.id, tipo: "variavel",
        forma_pagamento: "cartao", cartao_id: cartao.id, parcelado: false
      )

      expect(Despesa.count).to eq(3)
      expect(DespesasFiltradas.call.size).to eq(4)
    end
  end

  describe "Parcelamento (despesa parcelada fora do cartão)" do
    it "inclui o Parcelamento na listagem, marcado como não-despesa" do
      resultado = CriarParcelamento.call(
        valor_total: 300, numero_parcelas: 3, data: Date.new(2026, 4, 5),
        categoria_id: transporte.id, tipo: "variavel", forma_pagamento: "boleto"
      )
      parcelamento = resultado.valor

      item = DespesasFiltradas.call.find { |i| i.registro == parcelamento }

      expect(item).not_to be_nil
      expect(item).not_to be_despesa
      expect(item).to be_parcelamento
      expect(item.categoria_nome).to eq("Transporte")
      expect(item.valor).to eq(300.to_d)
    end

    it "não aparece quando o filtro é por cartão, igual à Despesa" do
      CriarParcelamento.call(
        valor_total: 300, numero_parcelas: 3, data: Date.new(2026, 4, 5),
        categoria_id: transporte.id, tipo: "variavel", forma_pagamento: "boleto"
      )

      resultado = DespesasFiltradas.call(cartao_id: cartao.id)

      expect(resultado).to be_empty
    end
  end

  describe "filtro por cartão (drill-down do Painel)" do
    it "restringe a listagem só às compras com categoria daquele cartão, excluindo Despesa" do
      outro_cartao = Cartao.create!(nome: "Gold", credor: credor, limite_total: 3000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 1, 1))
      CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 4, 5), valor_total: 200, parcelado: false, categoria_id: transporte.id)
      CriarCompraNoCartao.call(cartao_id: outro_cartao.id, data_compra: Date.new(2026, 4, 6), valor_total: 90, parcelado: false, categoria_id: transporte.id)

      resultado = DespesasFiltradas.call(cartao_id: cartao.id)

      expect(resultado.size).to eq(1)
      expect(resultado.first.valor).to eq(200.to_d)
    end
  end
end
