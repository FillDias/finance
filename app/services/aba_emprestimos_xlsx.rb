# Cronograma completo — inclui parcela já paga também, não só as pendentes
# (ver AC do ticket #13).
class AbaEmprestimosXlsx
  def self.adicionar(package)
    package.workbook.add_worksheet(name: "Empréstimos") do |sheet|
      cabecalho = sheet.styles.add_style(b: true)
      sheet.add_row [ "Empréstimo", "Credor", "Vencimento", "Valor", "Status" ], style: cabecalho

      Emprestimo.includes(:credor, :parcelas).order(:nome).each do |emprestimo|
        emprestimo.parcelas.order(:data_vencimento).each do |parcela|
          sheet.add_row [ emprestimo.nome, emprestimo.credor.nome, parcela.data_vencimento, parcela.valor, parcela.status_label ]
        end
      end
    end
  end
end
