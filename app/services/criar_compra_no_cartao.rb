class CriarCompraNoCartao < ApplicationService
  def initialize(cartao_id:, data_compra:, valor_total:, parcelado:, numero_parcelas: nil, categoria_id: nil, tipo: nil)
    @cartao_id = cartao_id
    @data_compra_bruta = data_compra
    @valor_total = valor_total
    @parcelado = ActiveModel::Type::Boolean.new.cast(parcelado)
    @numero_parcelas = @parcelado ? numero_parcelas : 1
    @categoria_id = categoria_id
    @tipo = tipo
  end

  def call
    cartao = Cartao.find_by(id: @cartao_id)
    return Resultado.erro("Cartão não encontrado") unless cartao

    data_compra = normalizar_data(@data_compra_bruta)
    return Resultado.erro("Data da compra inválida") unless data_compra

    if data_compra < cartao.data_corte
      return Resultado.erro(
        "Compra deve ser feita a partir da data de corte do cartão (#{cartao.data_corte.strftime('%d/%m/%Y')})"
      )
    end

    compra = Compra.new(
      cartao: cartao, data_compra: data_compra, valor_total: @valor_total,
      parcelado: @parcelado, numero_parcelas: @numero_parcelas,
      categoria_id: @categoria_id, tipo: @tipo
    )
    return Resultado.erro(*compra.errors.full_messages, valor: compra) unless compra.valid?

    parcelas_calculadas = GerarParcelas.call(
      valor_total: compra.valor_total, numero_parcelas: compra.numero_parcelas, data_compra: compra.data_compra,
      dia_fechamento: cartao.dia_fechamento, dia_vencimento: cartao.dia_vencimento
    )

    ActiveRecord::Base.transaction do
      compra.save!
      parcelas_calculadas.valor.each do |dados|
        compra.parcelas.create!(valor: dados[:valor], data_vencimento: dados[:data_vencimento], status: :pendente)
      end
    end

    Resultado.sucesso(valor: compra)
  end

  private

  def normalizar_data(valor)
    valor.is_a?(Date) ? valor : Date.parse(valor.to_s)
  rescue ArgumentError, TypeError
    nil
  end
end
