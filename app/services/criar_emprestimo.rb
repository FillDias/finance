class CriarEmprestimo < ApplicationService
  include ParseiaValorEData

  def initialize(nome:, credor_id:, valor_total:, cronograma_texto:)
    @nome = nome
    @credor_id = credor_id
    @valor_total = valor_total
    @cronograma_texto = cronograma_texto.to_s
  end

  def call
    emprestimo = Emprestimo.new(nome: @nome, credor_id: @credor_id, valor_total: @valor_total, cronograma_texto: @cronograma_texto)
    return Resultado.erro(*emprestimo.errors.full_messages, valor: emprestimo) unless emprestimo.valid?

    linhas = @cronograma_texto.split("\n").map(&:strip).reject(&:empty?)
    return Resultado.erro("Informe ao menos uma parcela no cronograma", valor: emprestimo) if linhas.empty?

    parcelas_para_criar = []
    erros = []

    linhas.each_with_index do |linha, indice|
      dados = processar_linha(linha, indice + 1)
      dados[:erro] ? erros << dados[:erro] : parcelas_para_criar << dados
    end

    return Resultado.erro(*erros, valor: emprestimo) if erros.any?

    ActiveRecord::Base.transaction do
      emprestimo.save!
      parcelas_para_criar.each do |dados|
        emprestimo.parcelas.create!(valor: dados[:valor], data_vencimento: dados[:data_vencimento], status: :pendente)
      end
    end

    Resultado.sucesso(valor: emprestimo)
  end

  private

  def processar_linha(linha, numero_da_linha)
    partes = linha.split(",")
    return { erro: "Linha #{numero_da_linha}: formato inválido (esperado \"data,valor\")" } unless partes.size == 2

    data = parsear_data(partes[0])
    return { erro: "Linha #{numero_da_linha}: data inválida (\"#{partes[0]}\")" } unless data

    valor = parsear_valor(partes[1])
    return { erro: "Linha #{numero_da_linha}: valor inválido (\"#{partes[1]}\")" } unless valor && valor > 0

    { data_vencimento: data, valor: valor }
  end
end
