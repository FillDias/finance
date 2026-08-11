require "rails_helper"

RSpec.describe AtualizarCartao do
  let(:credor) { Credor.create!(nome: "Nubank") }
  let(:outro_credor) { Credor.create!(nome: "Santander") }

  it "atualiza o cartão e retorna sucesso quando os dados são válidos" do
    cartao = Cartao.create!(nome: "Nubank Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.current)

    resultado = AtualizarCartao.call(
      cartao: cartao, nome: "Nubank Gold", credor_id: outro_credor.id, limite_total: 8000,
      dia_fechamento: 10, dia_vencimento: 17, data_corte: Date.current
    )

    expect(resultado).to be_sucesso
    expect(cartao.reload.nome).to eq("Nubank Gold")
    expect(cartao.credor_id).to eq(outro_credor.id)
  end

  it "não atualiza e retorna erro quando os dados são inválidos" do
    cartao = Cartao.create!(nome: "Nubank Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.current)

    resultado = AtualizarCartao.call(
      cartao: cartao, nome: "Nubank Gold", credor_id: credor.id, limite_total: 8000,
      dia_fechamento: 40, dia_vencimento: 17, data_corte: Date.current
    )

    expect(resultado).to be_erro
    expect(cartao.reload.nome).to eq("Nubank Ultravioleta")
  end
end
