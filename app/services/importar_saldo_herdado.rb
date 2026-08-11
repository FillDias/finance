require "csv"

class ImportarSaldoHerdado < ApplicationService
  include ParseiaValorEData

  COLUNAS_ESPERADAS = %w[credor cartao mes_referencia valor_total].freeze

  def initialize(conteudo_csv:)
    @conteudo_csv = conteudo_csv
  end

  def call
    tabela = ler_csv
    return Resultado.erro("Arquivo CSV inválido: #{@erro_de_leitura}") if tabela.nil?

    unless cabecalho_valido?(tabela)
      return Resultado.erro("Cabeçalho inválido. Colunas esperadas: #{COLUNAS_ESPERADAS.join(', ')}")
    end

    erros = []
    saldos_criados = 0

    ActiveRecord::Base.transaction do
      tabela.each.with_index(2) do |linha, numero_da_linha|
        erro = processar_linha(linha, numero_da_linha)
        erro ? erros << erro : saldos_criados += 1
      end

      raise ActiveRecord::Rollback if erros.any?
    end

    erros.any? ? Resultado.erro(*erros) : Resultado.sucesso(valor: saldos_criados)
  end

  private

  def ler_csv
    CSV.parse(@conteudo_csv.to_s, headers: true)
  rescue CSV::MalformedCSVError => e
    @erro_de_leitura = e.message
    nil
  end

  def cabecalho_valido?(tabela)
    (COLUNAS_ESPERADAS - tabela.headers.to_a.compact.map(&:strip)).empty?
  end

  def processar_linha(linha, numero_da_linha)
    credor = Credor.find_by(nome: linha["credor"].to_s.strip)
    return "Linha #{numero_da_linha}: credor \"#{linha['credor']}\" não encontrado" unless credor

    cartao = credor.cartoes.find_by(nome: linha["cartao"].to_s.strip)
    unless cartao
      return "Linha #{numero_da_linha}: cartão \"#{linha['cartao']}\" não encontrado para o credor \"#{credor.nome}\""
    end

    mes_referencia = parsear_data(linha["mes_referencia"])
    return "Linha #{numero_da_linha}: mês de referência inválido (\"#{linha['mes_referencia']}\")" unless mes_referencia

    valor_total = parsear_valor(linha["valor_total"])
    return "Linha #{numero_da_linha}: valor total inválido (\"#{linha['valor_total']}\")" unless valor_total

    saldo = SaldoHerdado.new(cartao: cartao, mes_referencia: mes_referencia, valor_total: valor_total)
    return "Linha #{numero_da_linha}: #{saldo.errors.full_messages.join('; ')}" unless saldo.valid?

    saldo.save!
    nil
  end
end
