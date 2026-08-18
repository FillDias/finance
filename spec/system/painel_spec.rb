require "rails_helper"

RSpec.describe "Painel", type: :system do
  before do
    driven_by :selenium_chrome_headless
    selecionar_perfil
  end

  it "atualiza os KPIs ao trocar o filtro de mês, sem recarregar a página inteira" do
    Renda.create!(valor: 700, data: Date.new(2026, 5, 10), fonte: "Salário")
    Renda.create!(valor: 1500, data: Date.current, fonte: "Salário")

    visit root_path

    expect(page).to have_content("R$ 1.500,00")

    # Marca a página com um atributo que só sobreviveria a uma navegação
    # dentro do Turbo Frame — um reload de página inteira apagaria isso.
    page.execute_script("document.body.dataset.marcador = 'sem-reload'")

    find_field("Mês").set(Date.new(2026, 5, 1))
    click_button "Filtrar"

    expect(page).to have_content("R$ 700,00")
    expect(page).not_to have_content("R$ 1.500,00")
    expect(page.evaluate_script("document.body.dataset.marcador")).to eq("sem-reload")
    expect(page.current_path).to eq(root_path)
  end

  it "exclui uma despesa da lista de lançamentos sem recarregar a página inteira" do
    categoria = Categoria.create!(nome: "Mercado")
    Despesa.create!(valor: 90, data: Date.current, categoria: categoria, tipo: :variavel, forma_pagamento: :dinheiro)

    visit root_path
    expect(page).to have_content("R$ 90,00")

    page.execute_script("document.body.dataset.marcador = 'sem-reload'")

    accept_confirm { click_button "Excluir" }

    expect(page).to have_content("Nenhum lançamento neste período.")
    expect(page.evaluate_script("document.body.dataset.marcador")).to eq("sem-reload")
    expect(page.current_path).to eq(root_path)
    expect(Despesa.count).to eq(0)
  end
end
