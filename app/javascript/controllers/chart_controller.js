// Convenção: qualquer gráfico do sistema é renderizado por este único
// controller. Uma query no backend prepara os dados já no formato de
// opções do ECharts; a view serializa esse resultado como JSON num
// data-attribute; este controller só instancia o gráfico e aplica a config.
//
//   <div data-controller="chart" data-chart-option-value="<%= raw(minha_query_result.to_json) %>"></div>
//
// Drill-down (opcional): se um item de dado do gráfico carrega uma `chave`
// (ver Grafico*Query#barra/#fatia) e o elemento tem os values frame/param,
// clicar no item atualiza o `src` de um turbo-frame com esse filtro — sem
// esses values, o listener de clique nem é registrado, então gráficos sem
// drill-down (ex.: Investimentos) continuam funcionando do mesmo jeito.
// `extra-params` carrega o resto do estado de filtro da tela (ex.: mês,
// categoria/cartão já selecionados) como um objeto JSON genérico — este
// controller não conhece os nomes dos filtros de nenhuma tela específica.
//
//   <div data-controller="chart" data-chart-option-value="..."
//        data-chart-frame-value="lancamentos-frame" data-chart-param-value="categoria_id"
//        data-chart-base-url-value="<%= root_path %>"
//        data-chart-extra-params-value="<%= { mes: @mes.iso8601, cartao_id: @cartao_id }.compact.to_json %>"></div>
//
import { Controller } from "@hotwired/stimulus"
import * as echarts from "echarts"

export default class extends Controller {
  static values = { option: Object, frame: String, param: String, baseUrl: String, extraParams: Object }

  connect() {
    this.chart = echarts.init(this.element)
    this.chart.setOption(this.optionValue)
    this.resizeHandler = () => this.chart.resize()
    window.addEventListener("resize", this.resizeHandler)

    if (this.hasFrameValue && this.hasParamValue) {
      this.chart.on("click", (params) => this.drilldown(params))
    }
  }

  disconnect() {
    window.removeEventListener("resize", this.resizeHandler)
    this.chart.dispose()
  }

  drilldown(params) {
    const chave = params.data && params.data.chave
    if (chave === undefined || chave === null) return

    const frame = document.getElementById(this.frameValue)
    if (!frame) return

    const url = new URL(this.baseUrlValue, window.location.origin)
    Object.entries(this.extraParamsValue || {}).forEach(([key, value]) => url.searchParams.set(key, value))
    url.searchParams.set(this.paramValue, chave)

    frame.src = url.toString()
  }
}
