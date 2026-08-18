require "rails_helper"

RSpec.describe "Troca de Perfil", type: :system do
  before { driven_by :selenium_chrome_headless }

  it "pede pra escolher um perfil antes de mostrar o Painel, e troca depois via menu" do
    Perfil.create!(nome: "Fill")
    Perfil.create!(nome: "Fernanda")

    visit root_path

    expect(page).to have_current_path(perfis_path)
    expect(page).to have_button("Fill")
    expect(page).to have_button("Fernanda")

    click_button "Fill"

    expect(page).to have_current_path(root_path)

    click_button "Mais"
    click_link "Trocar perfil"

    expect(page).to have_current_path(perfis_path)

    click_button "Fernanda"

    expect(page).to have_current_path(root_path)
  end
end
