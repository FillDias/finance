require "rails_helper"

RSpec.describe CriarCartao do
  let(:credor) { Credor.create!(nome: "Nubank") }

  it "cria o cartão e retorna sucesso quando os dados são válidos" do
    resultado = CriarCartao.call(
      nome: "Nubank Ultravioleta", credor_id: credor.id, limite_total: 5000,
      dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.current
    )

    expect(resultado).to be_sucesso
    expect(resultado.valor).to be_persisted
    expect(Cartao.count).to eq(1)
  end

  it "não cria e retorna erro quando os dados são inválidos" do
    resultado = CriarCartao.call(
      nome: "Nubank Ultravioleta", credor_id: credor.id, limite_total: -5,
      dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.current
    )

    expect(resultado).to be_erro
    expect(Cartao.count).to eq(0)
  end
end
