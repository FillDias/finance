# Cabeçalho em negrito, compartilhado entre todas as Aba*Xlsx (evita repetir
# o mesmo add_style/add_row em cada uma).
module CabecalhoXlsx
  def adicionar_cabecalho(sheet, colunas)
    estilo = sheet.styles.add_style(b: true)
    sheet.add_row colunas, style: estilo
  end
end
