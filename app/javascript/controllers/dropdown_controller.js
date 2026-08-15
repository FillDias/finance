// Dropdown do menu do topo (ver ADR 0006). Cada grupo (Lançamentos, Dívidas,
// Mais) tem sua própria instância — abre no clique do botão, fecha sozinho
// ao clicar fora ou de novo no botão. Mutuamente exclusivo: abrir um grupo
// fecha qualquer outro dropdown já aberto na página (via evento customizado
// no document, sem cada instância precisar conhecer as outras).
import { Controller } from "@hotwired/stimulus"

const EVENTO_ABRIU = "dropdown:abriu"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    this.fecharSeClicouFora = (event) => {
      if (!this.element.contains(event.target)) this.fechar()
    }
    this.fecharSeOutroAbriu = (event) => {
      if (event.detail.origem !== this.element) this.fechar()
    }
    document.addEventListener("click", this.fecharSeClicouFora)
    document.addEventListener(EVENTO_ABRIU, this.fecharSeOutroAbriu)
  }

  disconnect() {
    document.removeEventListener("click", this.fecharSeClicouFora)
    document.removeEventListener(EVENTO_ABRIU, this.fecharSeOutroAbriu)
  }

  toggle(event) {
    event.stopPropagation()
    this.menuTarget.classList.contains("aberto") ? this.fechar() : this.abrir()
  }

  abrir() {
    document.dispatchEvent(new CustomEvent(EVENTO_ABRIU, { detail: { origem: this.element } }))
    this.menuTarget.classList.add("aberto")
    this.element.setAttribute("aria-expanded", "true")
    this.ajustarAlinhamento()
  }

  fechar() {
    this.menuTarget.classList.remove("aberto")
    this.element.setAttribute("aria-expanded", "false")
    this.menuTarget.classList.remove("alinhar-direita")
  }

  // Se o dropdown, alinhado à esquerda por padrão, ultrapassaria a borda
  // direita da janela, alinha à direita (cresce pra esquerda) em vez disso.
  ajustarAlinhamento() {
    this.menuTarget.classList.remove("alinhar-direita")
    const { right } = this.menuTarget.getBoundingClientRect()
    if (right > window.innerWidth) this.menuTarget.classList.add("alinhar-direita")
  }
}
