# Paleta de docs/design-visual.md, disponível pras queries que montam
# opções do ECharts (JSON puro — não alcança as variáveis do CSS).
module PaletaGrafico
  POSITIVO = "#1e8e3e"
  NEGATIVO = "#c0392b"
  GRADIENTE_CLARO = "#a9c4e8"
  GRADIENTE_ESCURO = "#0b2e5c"
  CABECALHO_FUNDO = "#101b2d"
  TEXTO_SECUNDARIO = "#6b7280"

  # Gradiente linear pronto pro itemStyle.color de uma série de barras do
  # ECharts (JSON puro, não uma função — ver chart_controller.js).
  def self.gradiente_linear(x2: 1, y2: 0)
    {
      type: "linear", x: 0, y: 0, x2: x2, y2: y2,
      colorStops: [
        { offset: 0, color: GRADIENTE_CLARO },
        { offset: 1, color: GRADIENTE_ESCURO }
      ]
    }
  end

  # Uma cor por fatia dentro do gradiente de azul, ranqueada pela posição no
  # array (índice 0 = mais clara) — usado quando cada fatia de um gráfico de
  # rosca precisa de uma cor própria, mas ainda dentro da paleta de azul do
  # guia de design.
  def self.interpolar_azul(indice, total)
    return GRADIENTE_ESCURO if total <= 1

    fator = indice / (total - 1).to_f
    claro = GRADIENTE_CLARO.delete_prefix("#").scan(/../).map { |h| h.to_i(16) }
    escuro = GRADIENTE_ESCURO.delete_prefix("#").scan(/../).map { |h| h.to_i(16) }
    mistura = claro.zip(escuro).map { |c, e| (c + (e - c) * fator).round }

    format("#%02x%02x%02x", *mistura)
  end
end
