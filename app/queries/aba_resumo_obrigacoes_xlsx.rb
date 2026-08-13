# Coluna "Tipo" (não "Categoria" — esse termo já é o rótulo de
# Despesa/Compra no glossário, ver CONTEXT.md) distingue Cartão de
# Empréstimo.
class AbaResumoObrigacoesXlsx < ApplicationQuery
  include CabecalhoXlsx

  def initialize(package:)
    @package = package
  end

  def call
    @package.workbook.add_worksheet(name: "Resumo de Obrigações") do |sheet|
      adicionar_cabecalho(sheet, [ "Credor", "Saldo Restante", "Tipo" ])

      Cartao.includes(:credor).order(:nome).each do |cartao|
        sheet.add_row [ cartao.credor.nome, SaldoRestanteQuery.call(cartao: cartao), "Cartão" ]
      end

      Emprestimo.includes(:credor).order(:nome).each do |emprestimo|
        sheet.add_row [ emprestimo.credor.nome, SaldoRestanteEmprestimoQuery.call(emprestimo: emprestimo), "Empréstimo" ]
      end
    end
  end
end
