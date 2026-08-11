require "rails_helper"

RSpec.describe CriarSaldoHerdado do
  let(:credor) { Credor.create!(nome: "Nubank") }
  let(:cartao) { Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 6, 1)) }

  it "cria o saldo herdado e retorna sucesso quando os dados são válidos" do
    resultado = CriarSaldoHerdado.call(cartao_id: cartao.id, mes_referencia: Date.new(2026, 1, 1), valor_total: 1200)

    expect(resultado).to be_sucesso
    expect(resultado.valor).to be_persisted
  end

  it "não cria e retorna erro quando os dados são inválidos" do
    resultado = CriarSaldoHerdado.call(cartao_id: cartao.id, mes_referencia: Date.new(2026, 1, 1), valor_total: -10)

    expect(resultado).to be_erro
    expect(SaldoHerdado.count).to eq(0)
  end
end
