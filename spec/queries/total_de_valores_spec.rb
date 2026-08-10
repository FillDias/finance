require "rails_helper"

RSpec.describe TotalDeValores do
  it "soma uma lista de valores" do
    expect(TotalDeValores.call([10, 20, 30])).to eq(60)
  end

  it "retorna zero para uma lista vazia" do
    expect(TotalDeValores.call([])).to eq(0)
  end
end
