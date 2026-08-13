class AbaReceitasXlsx
  def self.adicionar(package)
    package.workbook.add_worksheet(name: "Receitas") do |sheet|
      cabecalho = sheet.styles.add_style(b: true)
      sheet.add_row [ "Data", "Valor", "Fonte" ], style: cabecalho

      Renda.order(data: :desc).each do |renda|
        sheet.add_row [ renda.data, renda.valor, renda.fonte ]
      end
    end
  end
end
