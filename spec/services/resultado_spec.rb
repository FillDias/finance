require "rails_helper"

RSpec.describe Resultado do
  describe ".sucesso" do
    it "é sucesso e carrega o valor" do
      resultado = Resultado.sucesso(valor: 42)

      expect(resultado).to be_sucesso
      expect(resultado).not_to be_erro
      expect(resultado.valor).to eq(42)
      expect(resultado.erros).to eq([])
    end
  end

  describe ".erro" do
    it "é erro e carrega as mensagens" do
      resultado = Resultado.erro("mensagem um", "mensagem dois")

      expect(resultado).to be_erro
      expect(resultado).not_to be_sucesso
      expect(resultado.erros).to eq(["mensagem um", "mensagem dois"])
    end

    it "pode carregar um valor junto com o erro, para re-exibir um registro inválido" do
      resultado = Resultado.erro("inválido", valor: "registro parcial")

      expect(resultado.valor).to eq("registro parcial")
    end
  end
end
