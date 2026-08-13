require "rails_helper"

RSpec.describe SaldoRestanteEmprestimoQuery do
  it "soma as parcelas pendentes e atrasadas, ignorando as pagas" do
    credor = Credor.create!(nome: "Nubank")
    resultado = CriarEmprestimo.call(
      nome: "Financiamento", credor_id: credor.id, valor_total: 3000,
      cronograma_texto: "2026-08-15,1000.00\n2026-09-15,1000.00\n2026-10-15,1000.00"
    )
    emprestimo = resultado.valor
    MarcarParcelaComoPaga.call(parcela: emprestimo.parcelas.first)

    expect(SaldoRestanteEmprestimoQuery.call(emprestimo: emprestimo)).to eq(2000.to_d)
  end

  it "zero quando todas as parcelas estão pagas" do
    credor = Credor.create!(nome: "Nubank")
    resultado = CriarEmprestimo.call(nome: "Financiamento", credor_id: credor.id, valor_total: 1000, cronograma_texto: "2026-08-15,1000.00")
    emprestimo = resultado.valor
    MarcarParcelaComoPaga.call(parcela: emprestimo.parcelas.first)

    expect(SaldoRestanteEmprestimoQuery.call(emprestimo: emprestimo)).to eq(0)
  end
end
