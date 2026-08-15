require "rails_helper"

RSpec.describe "Painel", type: :request do
  let(:mercado) { Categoria.create!(nome: "Mercado") }
  let(:lazer) { Categoria.create!(nome: "Lazer") }
  let(:credor) { Credor.create!(nome: "Nubank") }
  let(:cartao) { Cartao.create!(nome: "Ultravioleta", credor: credor, limite_total: 5000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 1, 1)) }

  describe "GET /" do
    it "renderiza os KPIs do mês atual e os 10 gráficos (4 sparklines + 6 principais)" do
      Renda.create!(valor: 1000, data: Date.current, fonte: "Salário")
      Despesa.create!(valor: 400, data: Date.current, categoria: mercado, tipo: :variavel, forma_pagamento: :dinheiro)

      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("R$ 1.000,00")
      expect(response.body.scan('data-controller="chart"').size).to eq(10)
      expect(response.body).to include('turbo-frame id="painel-conteudo"')
      expect(response.body).to include('turbo-frame id="lancamentos-frame"')
    end

    it "usa o mês do parâmetro `mes` pros KPIs, não o mês atual" do
      Renda.create!(valor: 700, data: Date.new(2026, 5, 10), fonte: "Salário")
      Renda.create!(valor: 300, data: Date.current, fonte: "Salário")

      get root_path(mes: "2026-05-01")

      expect(response.body).to include("R$ 700,00")
    end

    it "filtra a tabela de lançamentos por categoria sem afetar os KPIs" do
      Despesa.create!(valor: 200, data: Date.current, categoria: mercado, tipo: :variavel, forma_pagamento: :dinheiro)
      Despesa.create!(valor: 150, data: Date.current, categoria: lazer, tipo: :variavel, forma_pagamento: :pix)

      get root_path(categoria_id: mercado.id)

      expect(response.body).to include("Lançamentos do período (filtrado)")
      expect(response.body).to include("R$ 350,00") # KPI de saídas continua somando as duas categorias
    end

    it "filtra a tabela de lançamentos por cartão, restringindo às compras daquele cartão" do
      outro_cartao = Cartao.create!(nome: "Gold", credor: credor, limite_total: 3000, dia_fechamento: 5, dia_vencimento: 12, data_corte: Date.new(2026, 1, 1))
      CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.current.beginning_of_month, valor_total: 500, parcelado: false, categoria_id: mercado.id)
      CriarCompraNoCartao.call(cartao_id: outro_cartao.id, data_compra: Date.current.beginning_of_month, valor_total: 90, parcelado: false, categoria_id: mercado.id)

      get root_path(cartao_id: cartao.id)

      linhas = Nokogiri::HTML::Document.parse(response.body).css("#lancamentos-frame tbody tr")

      expect(response.body).to include("Lançamentos do período (filtrado)")
      expect(linhas.size).to eq(1)
      expect(linhas.first.text).to include("R$ 500,00")
    end

    it "renderiza a Central de Obrigações e os próximos vencimentos com dado real" do
      SaldoHerdado.create!(cartao: cartao, mes_referencia: Date.current.beginning_of_month, valor_total: 800)

      get root_path

      expect(response.body).to include("Central de Obrigações")
      expect(response.body).to include("Saldo Herdado")
      expect(response.body).to include("Próximos vencimentos")
      expect(response.body).to include("Ultravioleta")
    end

    it "mostra o botão de excluir só nas linhas de Despesa e Parcelamento, não nas de Compra" do
      Despesa.create!(valor: 400, data: Date.current, categoria: mercado, tipo: :variavel, forma_pagamento: :dinheiro)
      CriarCompraNoCartao.call(cartao_id: cartao.id, data_compra: Date.current.beginning_of_month, valor_total: 500, parcelado: false, categoria_id: mercado.id)
      CriarParcelamento.call(valor_total: 300, numero_parcelas: 3, data: Date.current, categoria_id: mercado.id, tipo: "variavel", forma_pagamento: "boleto")

      get root_path

      linhas = Nokogiri::HTML::Document.parse(response.body).css("#lancamentos-frame tbody tr")
      linhas_com_excluir = linhas.select { |linha| linha.at_css("form[action^='/despesas'], form[action^='/parcelamentos']") }

      expect(linhas.size).to eq(3)
      expect(linhas_com_excluir.size).to eq(2)
    end

    it "não quebra quando não há nenhum dado cadastrado" do
      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Nenhuma obrigação neste mês.")
      expect(response.body).to include("Nenhum vencimento em aberto.")
      expect(response.body).to include("Nenhum lançamento neste período.")
    end
  end
end
