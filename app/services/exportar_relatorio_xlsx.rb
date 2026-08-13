# Monta um pacote XLSX com uma ou mais abas. Cada botão de exportar (por
# módulo) pede só a aba correspondente; o botão único do Painel pede todas
# (padrão, sem argumento).
class ExportarRelatorioXlsx < ApplicationService
  CONTENT_TYPE = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"

  ABAS = {
    receitas: AbaReceitasXlsx,
    despesas: AbaDespesasXlsx,
    cartoes: AbaCartoesXlsx,
    emprestimos: AbaEmprestimosXlsx,
    resumo_obrigacoes: AbaResumoObrigacoesXlsx
  }.freeze

  def initialize(abas: ABAS.keys)
    @abas = abas
  end

  def call
    package = Axlsx::Package.new
    @abas.each { |aba| ABAS.fetch(aba).call(package: package) }

    Resultado.sucesso(valor: package)
  end
end
