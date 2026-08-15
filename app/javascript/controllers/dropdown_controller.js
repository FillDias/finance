// Dropdown do menu do topo (ver ADR 0006). Cada grupo (Lançamentos, Dívidas,
// Mais) tem sua própria instância — abre no clique do botão, fecha sozinho
// ao clicar fora ou de novo no botão. Sem coordenação entre instâncias: não
// há um "recolher tudo", cada dropdown é independente.
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.fecharSeClicouFora = (event) => {
      if (!this.element.contains(event.target)) this.fechar()
    }
    document.addEventListener("click", this.fecharSeClicouFora)
  }

  disconnect() {
    document.removeEventListener("click", this.fecharSeClicouFora)
  }

  toggle(event) {
    event.stopPropagation()
    this.menuTarget.classList.contains("aberto") ? this.fechar() : this.abrir()
  }

  abrir() {
    this.menuTarget.classList.add("aberto")
    this.element.setAttribute("aria-expanded", "true")
  }

  fechar() {
    this.menuTarget.classList.remove("aberto")
    this.element.setAttribute("aria-expanded", "false")
  }
}
