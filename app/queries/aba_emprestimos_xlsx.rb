# Cronograma completo — inclui parcela já paga também, não só as pendentes
# (ver AC do ticket #13).
class AbaEmprestimosXlsx < ApplicationQuery
  include CabecalhoXlsx

  def initialize(package:)
    @package = package
  end

  def call
    @package.workbook.add_worksheet(name: "Empréstimos") do |sheet|
      adicionar_cabecalho(sheet, [ "Empréstimo", "Credor", "Vencimento", "Valor", "Status" ])

      Emprestimo.includes(:credor, :parcelas).order(:nome).each do |emprestimo|
        emprestimo.parcelas.order(:data_vencimento).each do |parcela|
          sheet.add_row [ emprestimo.nome, emprestimo.credor.nome, parcela.data_vencimento, parcela.valor, parcela.status_label ]
        end
      end
    end
  end
end
