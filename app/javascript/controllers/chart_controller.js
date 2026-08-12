// Convenção: qualquer gráfico do sistema é renderizado por este único
// controller. Uma query no backend prepara os dados já no formato de
// opções do ECharts; a view serializa esse resultado como JSON num
// data-attribute; este controller só instancia o gráfico e aplica a config.
//
//   <div data-controller="chart" data-chart-option-value="<%= raw(minha_query_result.to_json) %>"></div>
//
import { Controller } from "@hotwired/stimulus"
import * as echarts from "echarts"

export default class extends Controller {
  static values = { option: Object }

  connect() {
    this.chart = echarts.init(this.element)
    this.chart.setOption(this.optionValue)
    this.resizeHandler = () => this.chart.resize()
    window.addEventListener("resize", this.resizeHandler)
  }

  disconnect() {
    window.removeEventListener("resize", this.resizeHandler)
    this.chart.dispose()
  }
}
