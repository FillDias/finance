require "rails_helper"

RSpec.describe CriarDespesa do
  let(:categoria) { Categoria.create!(nome: "Alimentação") }

  it "cria a despesa e retorna sucesso quando os dados são válidos" do
    resultado = CriarDespesa.call(
      valor: 80, data: Date.current, categoria_id: categoria.id, tipo: "variavel", forma_pagamento: "dinheiro"
    )

    expect(resultado).to be_sucesso
    expect(resultado.valor).to be_persisted
    expect(Despesa.count).to eq(1)
  end

  it "não cria e retorna erro quando despesa fixa não tem dia de vencimento" do
    resultado = CriarDespesa.call(
      valor: 120, data: Date.current, categoria_id: categoria.id, tipo: "fixa", forma_pagamento: "boleto"
    )

    expect(resultado).to be_erro
    expect(Despesa.count).to eq(0)
  end

  describe "quando forma_pagamento é cartão" do
    let(:credor) { Credor.create!(nome: "Nubank") }
    let(:cartao) do
      Cartao.create!(
        nome: "Ultravioleta", credor: credor, limite_total: 5000,
        dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 6, 1)
      )
    end

    it "cria uma Compra em vez de uma Despesa, carregando categoria e tipo" do
      resultado = CriarDespesa.call(
        valor: 150, data: Date.new(2026, 7, 3), categoria_id: categoria.id, tipo: "variavel",
        forma_pagamento: "cartao", cartao_id: cartao.id, parcelado: false
      )

      expect(resultado).to be_sucesso
      expect(resultado.valor).to be_a(Compra)
      expect(Despesa.count).to eq(0)
      expect(Compra.count).to eq(1)
      expect(resultado.valor.categoria).to eq(categoria)
      expect(resultado.valor.variavel?).to be true
    end

    it "gera parcelas quando a despesa no cartão é parcelada" do
      resultado = CriarDespesa.call(
        valor: 300, data: Date.new(2026, 7, 3), categoria_id: categoria.id, tipo: "variavel",
        forma_pagamento: "cartao", cartao_id: cartao.id, parcelado: true, numero_parcelas: 3
      )

      expect(resultado).to be_sucesso
      expect(resultado.valor.parcelas.count).to eq(3)
    end

    it "repassa o erro de CriarCompraNoCartao (ex.: compra antes da data de corte) sem criar nada" do
      resultado = CriarDespesa.call(
        valor: 150, data: Date.new(2026, 5, 3), categoria_id: categoria.id, tipo: "variavel",
        forma_pagamento: "cartao", cartao_id: cartao.id, parcelado: false
      )

      expect(resultado).to be_erro
      expect(Despesa.count).to eq(0)
      expect(Compra.count).to eq(0)
    end
  end

  describe "quando é parcelada sem ser no cartão" do
    it "cria um Parcelamento em vez de uma Despesa" do
      resultado = CriarDespesa.call(
        valor: 300, data: Date.new(2026, 7, 3), categoria_id: categoria.id, tipo: "variavel",
        forma_pagamento: "boleto", parcelado: true, numero_parcelas: 3
      )

      expect(resultado).to be_sucesso
      expect(resultado.valor).to be_a(Parcelamento)
      expect(Despesa.count).to eq(0)
      expect(resultado.valor.parcelas.count).to eq(3)
    end

    it "continua criando uma Despesa comum quando não é parcelada" do
      resultado = CriarDespesa.call(
        valor: 80, data: Date.current, categoria_id: categoria.id, tipo: "variavel",
        forma_pagamento: "dinheiro", parcelado: false
      )

      expect(resultado).to be_sucesso
      expect(resultado.valor).to be_a(Despesa)
      expect(Parcelamento.count).to eq(0)
    end
  end
end
