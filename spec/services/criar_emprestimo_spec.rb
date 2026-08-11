require "rails_helper"

RSpec.describe CriarEmprestimo do
  let(:credor) { Credor.create!(nome: "Caixa") }

  def cronograma(linhas)
    linhas.join("\n")
  end

  it "cria o empréstimo e o cronograma completo de parcelas" do
    resultado = CriarEmprestimo.call(
      nome: "Financiamento do carro", credor_id: credor.id, valor_total: 30000,
      cronograma_texto: cronograma([ "2026-08-15,450.00", "2026-09-15,450.00", "2026-10-15,450.00" ])
    )

    expect(resultado).to be_sucesso
    emprestimo = resultado.valor
    expect(emprestimo).to be_persisted
    expect(emprestimo.parcelas.count).to eq(3)
    expect(emprestimo.parcelas.order(:data_vencimento).pluck(:valor)).to eq([ 450.0.to_d, 450.0.to_d, 450.0.to_d ])
    expect(emprestimo.parcelas.first.pendente?).to be true
  end

  it "aceita parcelas de valores diferentes (cronograma real, não gerado automaticamente)" do
    resultado = CriarEmprestimo.call(
      nome: "Consignado", credor_id: credor.id, valor_total: 5000,
      cronograma_texto: cronograma([ "2026-08-15,1000.00", "2026-09-15,1500.00", "2026-10-15,2500.00" ])
    )

    expect(resultado).to be_sucesso
    expect(resultado.valor.parcelas.order(:data_vencimento).pluck(:valor)).to eq([ 1000.0.to_d, 1500.0.to_d, 2500.0.to_d ])
  end

  it "não cria nada quando os dados do empréstimo são inválidos" do
    resultado = CriarEmprestimo.call(
      nome: "", credor_id: credor.id, valor_total: 30000, cronograma_texto: cronograma([ "2026-08-15,450.00" ])
    )

    expect(resultado).to be_erro
    expect(Emprestimo.count).to eq(0)
  end

  it "não cria nada quando o cronograma está vazio" do
    resultado = CriarEmprestimo.call(nome: "Financiamento", credor_id: credor.id, valor_total: 30000, cronograma_texto: "")

    expect(resultado).to be_erro
    expect(Emprestimo.count).to eq(0)
  end

  it "rejeita o cronograma inteiro (tudo-ou-nada) quando uma linha tem data inválida" do
    resultado = CriarEmprestimo.call(
      nome: "Financiamento", credor_id: credor.id, valor_total: 30000,
      cronograma_texto: cronograma([ "2026-08-15,450.00", "data-invalida,450.00" ])
    )

    expect(resultado).to be_erro
    expect(resultado.erros.first).to include("Linha 2")
    expect(Emprestimo.count).to eq(0)
    expect(Parcela.count).to eq(0)
  end

  it "rejeita o cronograma inteiro quando uma linha tem valor inválido" do
    resultado = CriarEmprestimo.call(
      nome: "Financiamento", credor_id: credor.id, valor_total: 30000,
      cronograma_texto: cronograma([ "2026-08-15,não-é-um-valor" ])
    )

    expect(resultado).to be_erro
    expect(Emprestimo.count).to eq(0)
  end

  it "rejeita o cronograma inteiro quando uma linha tem formato errado" do
    resultado = CriarEmprestimo.call(
      nome: "Financiamento", credor_id: credor.id, valor_total: 30000,
      cronograma_texto: cronograma([ "2026-08-15,450.00,extra" ])
    )

    expect(resultado).to be_erro
    expect(Emprestimo.count).to eq(0)
  end

  it "ignora linhas em branco no cronograma" do
    resultado = CriarEmprestimo.call(
      nome: "Financiamento", credor_id: credor.id, valor_total: 30000,
      cronograma_texto: "2026-08-15,450.00\n\n2026-09-15,450.00\n"
    )

    expect(resultado).to be_sucesso
    expect(resultado.valor.parcelas.count).to eq(2)
  end
end
