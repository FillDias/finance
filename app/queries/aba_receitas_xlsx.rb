class AbaReceitasXlsx < ApplicationQuery
  include CabecalhoXlsx

  def initialize(package:)
    @package = package
  end

  def call
    @package.workbook.add_worksheet(name: "Receitas") do |sheet|
      adicionar_cabecalho(sheet, [ "Data", "Valor", "Fonte" ])

      Renda.order(data: :desc).each do |renda|
        sheet.add_row [ renda.data, renda.valor, renda.fonte ]
      end
    end
  end
end
