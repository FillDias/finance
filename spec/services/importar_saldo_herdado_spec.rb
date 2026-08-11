require "rails_helper"

RSpec.describe ImportarSaldoHerdado do
  let!(:nubank) { Credor.create!(nome: "Nubank") }
  let!(:santander) { Credor.create!(nome: "Santander") }
  let!(:ultravioleta) { Cartao.create!(nome: "Ultravioleta", credor: nubank, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 6, 1)) }
  let!(:free) { Cartao.create!(nome: "Free", credor: santander, limite_total: 3000, dia_fechamento: 10, dia_vencimento: 17, data_corte: Date.new(2026, 6, 1)) }

  def csv(linhas)
    ([ "credor,cartao,mes_referencia,valor_total" ] + linhas).join("\n")
  end

  it "importa várias linhas válidas, criando um saldo herdado por linha" do
    conteudo = csv([
      "Nubank,Ultravioleta,2026-01,1200.50",
      "Santander,Free,2026-01,850.00"
    ])

    resultado = ImportarSaldoHerdado.call(conteudo_csv: conteudo)

    expect(resultado).to be_sucesso
    expect(resultado.valor).to eq(2)
    expect(SaldoHerdado.count).to eq(2)
    expect(ultravioleta.saldos_herdados.first.valor_total).to eq(1200.50)
  end

  it "normaliza mes_referencia para o primeiro dia do mês informado" do
    conteudo = csv([ "Nubank,Ultravioleta,2026-01,1200.50" ])

    ImportarSaldoHerdado.call(conteudo_csv: conteudo)

    expect(SaldoHerdado.first.mes_referencia).to eq(Date.new(2026, 1, 1))
  end

  it "rejeita o arquivo inteiro (sem criar nada) quando o cabeçalho está incorreto" do
    conteudo = "banco,cartao,mes,valor\nNubank,Ultravioleta,2026-01,1200"

    resultado = ImportarSaldoHerdado.call(conteudo_csv: conteudo)

    expect(resultado).to be_erro
    expect(SaldoHerdado.count).to eq(0)
  end

  it "rejeita o arquivo inteiro quando um credor não existe" do
    conteudo = csv([
      "Nubank,Ultravioleta,2026-01,1200.50",
      "Inter,Cartão Inexistente,2026-01,500"
    ])

    resultado = ImportarSaldoHerdado.call(conteudo_csv: conteudo)

    expect(resultado).to be_erro
    expect(resultado.erros.first).to include("Linha 3")
    expect(SaldoHerdado.count).to eq(0)
  end

  it "rejeita o arquivo inteiro quando um cartão não existe para o credor informado" do
    conteudo = csv([ "Nubank,Cartão Errado,2026-01,1200.50" ])

    resultado = ImportarSaldoHerdado.call(conteudo_csv: conteudo)

    expect(resultado).to be_erro
    expect(SaldoHerdado.count).to eq(0)
  end

  it "rejeita o arquivo inteiro quando o mês de referência não é uma data válida" do
    conteudo = csv([ "Nubank,Ultravioleta,não-é-uma-data,1200.50" ])

    resultado = ImportarSaldoHerdado.call(conteudo_csv: conteudo)

    expect(resultado).to be_erro
    expect(SaldoHerdado.count).to eq(0)
  end

  it "rejeita o arquivo inteiro quando o valor total não é numérico" do
    conteudo = csv([ "Nubank,Ultravioleta,2026-01,não-é-um-número" ])

    resultado = ImportarSaldoHerdado.call(conteudo_csv: conteudo)

    expect(resultado).to be_erro
    expect(SaldoHerdado.count).to eq(0)
  end

  it "rejeita o arquivo inteiro quando o CSV está malformado" do
    conteudo = "credor,cartao,mes_referencia,valor_total\n\"Nubank,Ultravioleta,2026-01,1200.50"

    resultado = ImportarSaldoHerdado.call(conteudo_csv: conteudo)

    expect(resultado).to be_erro
  end

  it "rejeita a linha inteira quando já existe saldo herdado para aquele cartão e mês" do
    SaldoHerdado.create!(cartao: ultravioleta, mes_referencia: Date.new(2026, 1, 1), valor_total: 999)
    conteudo = csv([ "Nubank,Ultravioleta,2026-01,1200.50" ])

    resultado = ImportarSaldoHerdado.call(conteudo_csv: conteudo)

    expect(resultado).to be_erro
    expect(SaldoHerdado.count).to eq(1)
  end
end
