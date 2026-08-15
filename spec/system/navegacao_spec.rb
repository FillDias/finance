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
end
