# Reusa DespesasFiltradas — mesma regra de "mesma linha, nunca duas" que o
# resto do app usa pra combinar Despesa e Compra-com-categoria.
class AbaDespesasXlsx < ApplicationQuery
  include CabecalhoXlsx

  def initialize(package:)
    @package = package
  end

  def call
    @package.workbook.add_worksheet(name: "Despesas") do |sheet|
      adicionar_cabecalho(sheet, [ "Data", "Valor", "Categoria", "Forma de pagamento" ])

      DespesasFiltradas.call.each do |item|
        sheet.add_row [ item.data, item.valor, item.categoria_nome, item.forma_pagamento_label ]
      end
    end
  end
end
