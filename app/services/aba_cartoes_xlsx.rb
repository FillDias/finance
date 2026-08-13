class AbaCartoesXlsx
  def self.adicionar(package)
    package.workbook.add_worksheet(name: "Cartões") do |sheet|
      cabecalho = sheet.styles.add_style(b: true)
      sheet.add_row [ "Cartão", "Tipo", "Referência", "Valor", "Status" ], style: cabecalho

      Cartao.includes(:saldos_herdados, :parcelas).order(:nome).each do |cartao|
        linhas_saldo_herdado(cartao).each { |linha| sheet.add_row(linha) }
        linhas_parcelas(cartao).each { |linha| sheet.add_row(linha) }
      end
    end
  end

  def self.linhas_saldo_herdado(cartao)
    cartao.saldos_herdados.order(:mes_referencia).map do |saldo|
      status = saldo.valor_pago.present? ? "Quitado" : "Em aberto"
      [ cartao.nome, "Saldo Herdado", saldo.mes_referencia.strftime("%m/%Y"), saldo.valor_total, status ]
    end
  end

  def self.linhas_parcelas(cartao)
    cartao.parcelas.pendente.order(:data_vencimento).map do |parcela|
      [ cartao.nome, "Parcela", parcela.data_vencimento, parcela.valor, parcela.status_label ]
    end
  end
end
