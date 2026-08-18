require "rails_helper"

RSpec.describe Perfil, type: :model do
  it "é válido com nome" do
    expect(Perfil.new(nome: "Fill")).to be_valid
  end

  it "é inválido sem nome" do
    expect(Perfil.new(nome: nil)).not_to be_valid
  end

  it "é inválido com nome duplicado" do
    Perfil.create!(nome: "Fill")

    expect(Perfil.new(nome: "Fill")).not_to be_valid
  end
end
