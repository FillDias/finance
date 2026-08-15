require "rails_helper"

RSpec.describe "Menu de navegação", type: :system do
  before { driven_by :selenium_chrome_headless }

  it "abre um dropdown ao clicar, navega pro item e fecha ao clicar fora" do
    visit root_path

    expect(page).not_to have_link("Despesas", visible: :visible)

    click_button "Lançamentos"

    expect(page).to have_link("Despesas", visible: :visible)

    click_link "Despesas"

    expect(page).to have_current_path(despesas_path)
  end

  it "fecha o dropdown ao clicar fora, sem navegar" do
    visit root_path

    click_button "Lançamentos"
    expect(page).to have_link("Receitas", visible: :visible)

    find("body").click

    expect(page).not_to have_link("Receitas", visible: :visible)
  end

  it "é mutuamente exclusivo: abrir outro grupo fecha o que já estava aberto" do
    visit root_path

    click_button "Lançamentos"
    expect(page).to have_link("Receitas", visible: :visible)

    click_button "Dívidas"
    expect(page).to have_link("Cartões", visible: :visible)
    expect(page).not_to have_link("Receitas", visible: :visible)

    click_button "Mais"
    expect(page).to have_link("Investimentos", visible: :visible)
    expect(page).not_to have_link("Cartões", visible: :visible)
  end

  it "o dropdown \"Mais\" não fica cortado pela borda direita da janela" do
    visit root_path

    click_button "Mais"

    largura_da_janela = page.evaluate_script("window.innerWidth")
    borda_direita_do_dropdown = page.evaluate_script(
      "document.querySelector('.topnav-dropdown.aberto').getBoundingClientRect().right"
    )

    expect(borda_direita_do_dropdown).to be <= largura_da_janela
  end
end
