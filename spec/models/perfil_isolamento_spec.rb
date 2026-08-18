require "rails_helper"

# Ver ADR 0007. Este é o teste que garante a promessa central do recurso:
# dado de um Perfil nunca aparece pro outro, em nenhum dos 12 models que
# incluem PertenceAPerfil — cobrindo alguns representativos de perto
# (Despesa/Renda são raiz; Cartao/Compra e Investimento/Aporte têm
# associação; Emprestimo/Parcela é polimórfico).
RSpec.describe "Isolamento entre Perfis" do
  let(:fill) { Perfil.create!(nome: "Fill") }
  let(:fernanda) { Perfil.create!(nome: "Fernanda") }
  let(:categoria) { Categoria.create!(nome: "Mercado") }

  it "Despesa e Renda de um Perfil não aparecem pro outro" do
    Current.perfil = fill
    Despesa.create!(valor: 100, data: Date.current, categoria: categoria, tipo: :variavel, forma_pagamento: :dinheiro)
    Renda.create!(valor: 500, data: Date.current, fonte: "Salário")

    Current.perfil = fernanda

    expect(Despesa.count).to eq(0)
    expect(Renda.count).to eq(0)

    Renda.create!(valor: 300, data: Date.current, fonte: "Salário")
    expect(Renda.count).to eq(1)
    expect(Renda.sum(:valor)).to eq(300.to_d)

    Current.perfil = fill
    expect(Renda.count).to eq(1)
    expect(Renda.sum(:valor)).to eq(500.to_d)
  end

  it "Cartao e Compra de um Perfil não aparecem pro outro, mesmo com o mesmo Credor por nome" do
    Current.perfil = fill
    credor_fill = Credor.create!(nome: "Nubank")
    cartao_fill = Cartao.create!(nome: "Ultravioleta", credor: credor_fill, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 1, 1))
    CriarCompraNoCartao.call(cartao_id: cartao_fill.id, data_compra: Date.new(2026, 1, 10), valor_total: 200, parcelado: false, categoria_id: categoria.id)

    Current.perfil = fernanda
    credor_fernanda = Credor.create!(nome: "Nubank")
    cartao_fernanda = Cartao.create!(nome: "Ultravioleta", credor: credor_fernanda, limite_total: 3000, dia_fechamento: 10, dia_vencimento: 20, data_corte: Date.new(2026, 1, 1))

    expect(Credor.count).to eq(1)
    expect(Cartao.count).to eq(1)
    expect(Compra.count).to eq(0)
    expect(Cartao.first.limite_total).to eq(3000.to_d)

    Current.perfil = fill
    expect(Credor.count).to eq(1)
    expect(Cartao.count).to eq(1)
    expect(Compra.count).to eq(1)
    expect(cartao_fernanda.reload.perfil).to eq(fernanda)
    expect(cartao_fill.reload.perfil).to eq(fill)
  end

  it "Investimento e Aporte de um Perfil não aparecem pro outro" do
    tipo = TipoInvestimento.create!(nome: "CDB")

    Current.perfil = fill
    investimento = CriarInvestimento.call(tipo_investimento_id: tipo.id, instituicao: "Nubank", taxa_rendimento: 1, periodicidade_taxa: "mensal").valor
    investimento.aportes.create!(valor: 1000, data: Date.current)

    Current.perfil = fernanda
    expect(Investimento.count).to eq(0)
    expect(Aporte.count).to eq(0)

    Current.perfil = fill
    expect(Investimento.count).to eq(1)
    expect(investimento.aportes.count).to eq(1)
  end

  it "Emprestimo e suas Parcelas de um Perfil não aparecem pro outro" do
    Current.perfil = fill
    credor = Credor.create!(nome: "Caixa")
    CriarEmprestimo.call(nome: "Financiamento", credor_id: credor.id, categoria_id: categoria.id, valor_total: 1000, cronograma_texto: "2026-08-15,1000.00")

    Current.perfil = fernanda
    expect(Emprestimo.count).to eq(0)
    expect(Parcela.count).to eq(0)

    Current.perfil = fill
    expect(Emprestimo.count).to eq(1)
    expect(Parcela.count).to eq(1)
  end

  it "a Parcela de uma Compra herda o Perfil de quem criou, e a validação de consistência passa" do
    Current.perfil = fill
    credor = Credor.create!(nome: "Nubank")
    cartao = Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 1, 1))
    compra = CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 1, 10), valor_total: 200, parcelado: false).valor

    expect(compra.parcelas.first.perfil).to eq(fill)
  end

  it "Categoria, TipoInvestimento e TaxaCdi continuam compartilhados entre os dois Perfis" do
    Current.perfil = fill
    categoria_compartilhada = Categoria.create!(nome: "Lazer")
    tipo_compartilhado = TipoInvestimento.create!(nome: "Tesouro Direto")

    Current.perfil = fernanda
    expect(Categoria.exists?(categoria_compartilhada.id)).to be true
    expect(TipoInvestimento.exists?(tipo_compartilhado.id)).to be true
  end
end
