class AbaResumoDividasXlsx
  def self.adicionar(package)
    package.workbook.add_worksheet(name: "Resumo de Dívidas") do |sheet|
      cabecalho = sheet.styles.add_style(b: true)
      sheet.add_row [ "Credor", "Saldo Restante", "Categoria" ], style: cabecalho

      Cartao.includes(:credor).order(:nome).each do |cartao|
        sheet.add_row [ cartao.credor.nome, SaldoRestanteQuery.call(cartao: cartao), "Cartão" ]
      end

      Emprestimo.includes(:credor).order(:nome).each do |emprestimo|
        sheet.add_row [ emprestimo.credor.nome, SaldoRestanteEmprestimoQuery.call(emprestimo: emprestimo), "Empréstimo" ]
      end
    end
  end
end
