require "rails_helper"

RSpec.describe ExportarRelatorioXlsx do
  def linhas_da_aba(package, nome)
    aba = package.workbook.worksheets.find { |sheet| sheet.name == nome }
    aba.rows.map { |row| row.cells.map(&:value) }
  end

  describe "aba Receitas" do
    it "lista data, valor e fonte de cada Renda" do
      Renda.create!(valor: 1000, data: Date.new(2026, 3, 5), fonte: "Salário")

      linhas = linhas_da_aba(ExportarRelatorioXlsx.call(abas: [ :receitas ]).valor, "Receitas")

      expect(linhas.first).to eq([ "Data", "Valor", "Fonte" ])
      expect(linhas.second).to eq([ Date.new(2026, 3, 5), 1000.0, "Salário" ])
    end
  end

  describe "aba Despesas" do
    it "combina Despesa e Compra-com-categoria (mesma regra de DespesasFiltradas)" do
      categoria = Categoria.create!(nome: "Mercado")
      credor = Credor.create!(nome: "Nubank")
      cartao = Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 1, 1))
      Despesa.create!(valor: 200, data: Date.new(2026, 3, 5), categoria: categoria, tipo: :variavel, forma_pagamento: :dinheiro)
      CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 3, 1), valor_total: 300, parcelado: false, categoria_id: categoria.id)

      linhas = linhas_da_aba(ExportarRelatorioXlsx.call(abas: [ :despesas ]).valor, "Despesas")

      expect(linhas.first).to eq([ "Data", "Valor", "Categoria", "Forma de pagamento" ])
      expect(linhas.size).to eq(3)
      expect(linhas.map { |l| l[2] }).to include("Mercado")
    end
  end

  describe "aba Cartões" do
    it "lista Saldo Herdado por mês e Parcelas em aberto, por cartão" do
      credor = Credor.create!(nome: "Nubank")
      cartao = Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 1, 1))
      SaldoHerdado.create!(cartao: cartao, mes_referencia: Date.new(2026, 3, 1), valor_total: 800)
      CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.new(2026, 3, 1), valor_total: 300, parcelado: false)

      linhas = linhas_da_aba(ExportarRelatorioXlsx.call(abas: [ :cartoes ]).valor, "Cartões")

      expect(linhas.first).to eq([ "Cartão", "Tipo", "Referência", "Valor", "Status" ])
      expect(linhas).to include([ "Ultravioleta", "Saldo Herdado", "03/2026", 800.0, "Em aberto" ])
      expect(linhas.any? { |l| l[1] == "Parcela" && l[3] == 300.0 }).to be true
    end
  end

  describe "aba Empréstimos" do
    it "lista o cronograma completo de parcelas, incluindo as já pagas" do
      credor = Credor.create!(nome: "Nubank")
      resultado = CriarEmprestimo.call(nome: "Financiamento", credor_id: credor.id, valor_total: 2000, cronograma_texto: "2026-08-15,1000.00\n2026-09-15,1000.00")
      MarcarParcelaComoPaga.call(parcela: resultado.valor.parcelas.first)

      linhas = linhas_da_aba(ExportarRelatorioXlsx.call(abas: [ :emprestimos ]).valor, "Empréstimos")

      expect(linhas.first).to eq([ "Empréstimo", "Credor", "Vencimento", "Valor", "Status" ])
      expect(linhas.size).to eq(3)
      expect(linhas.map { |l| l[4] }).to include("Paga", "Pendente")
    end
  end

  describe "aba Resumo de Dívidas" do
    it "lista Credor, Saldo Restante e Categoria (Cartão ou Empréstimo)" do
      credor_cartao = Credor.create!(nome: "Nubank")
      cartao = Cartao.create!(nome: "Ultravioleta", credor: credor_cartao, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 1, 1))
      SaldoHerdado.create!(cartao: cartao, mes_referencia: Date.new(2026, 3, 1), valor_total: 800)

      credor_emprestimo = Credor.create!(nome: "Itaú")
      CriarEmprestimo.call(nome: "Financiamento", credor_id: credor_emprestimo.id, valor_total: 1000, cronograma_texto: "2026-08-15,1000.00")

      linhas = linhas_da_aba(ExportarRelatorioXlsx.call(abas: [ :resumo_dividas ]).valor, "Resumo de Dívidas")

      expect(linhas.first).to eq([ "Credor", "Saldo Restante", "Categoria" ])
      expect(linhas).to include([ "Nubank", 800.0, "Cartão" ])
      expect(linhas).to include([ "Itaú", 1000.0, "Empréstimo" ])
    end
  end

  describe "exportação combinada (botão único do Painel)" do
    it "inclui as 5 abas quando nenhum filtro é passado" do
      package = ExportarRelatorioXlsx.call.valor

      nomes = package.workbook.worksheets.map(&:name)
      expect(nomes).to contain_exactly("Receitas", "Despesas", "Cartões", "Empréstimos", "Resumo de Dívidas")
    end
  end
end
