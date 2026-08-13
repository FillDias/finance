# Reusa DespesasFiltradas — mesma regra de "mesma linha, nunca duas" que o
# resto do app usa pra combinar Despesa e Compra-com-categoria.
class AbaDespesasXlsx
  def self.adicionar(package)
    package.workbook.add_worksheet(name: "Despesas") do |sheet|
      cabecalho = sheet.styles.add_style(b: true)
      sheet.add_row [ "Data", "Valor", "Categoria", "Forma de pagamento" ], style: cabecalho

      DespesasFiltradas.call.each do |item|
        sheet.add_row [ item.data, item.valor, item.categoria_nome, item.forma_pagamento_label ]
      end
    end
  end
end
