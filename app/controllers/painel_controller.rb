class PainelController < ApplicationController
  def index
    @mes = mes_filtrado
    @categoria_id = params[:categoria_id].presence
    @cartao_id = params[:cartao_id].presence

    carregar_kpis
    carregar_graficos
    carregar_tabelas
    carregar_opcoes_de_filtro
  end

  def exportar
    resultado = ExportarRelatorioXlsx.call
    enviar_xlsx(resultado.valor, "relatorio-financeiro")
  end

  private

  def mes_filtrado
    Date.parse(params[:mes]).beginning_of_month
  rescue ArgumentError, TypeError
    Date.current.beginning_of_month
  end

  def carregar_kpis
    @entradas_do_mes = EntradasDoMesQuery.call(mes: @mes)
    @saidas_do_mes = SaidasDoMesQuery.call(mes: @mes, categoria_id: @categoria_id, cartao_id: @cartao_id)
    # Saldo = Entradas - Saídas (ver CONTEXT.md) é um número com significado
    # próprio; aplicar o filtro de Categoria/Cartão só no lado das Saídas
    # produziria um "saldo" que não bate com nenhum saldo de verdade, então
    # esse KPI (e sua sparkline) ficam de fora do filtro — não é "aplicável".
    @saldo_do_mes = SaldoDoMesQuery.call(mes: @mes)
    @obrigacoes_em_aberto = ObrigacoesEmAbertoQuery.call

    @sparkline_entradas = GraficoSparklineEntradasQuery.call
    @sparkline_saidas = GraficoSparklineSaidasQuery.call(categoria_id: @categoria_id, cartao_id: @cartao_id)
    @sparkline_saldo = GraficoSparklineSaldoQuery.call
    @sparkline_obrigacoes_em_aberto = GraficoSparklineObrigacoesEmAbertoQuery.call

    @comparacao_entradas = ComparacaoPeriodoQuery.call(mes: @mes) { |mes| EntradasDoMesQuery.call(mes: mes) }
    @comparacao_saidas = ComparacaoPeriodoQuery.call(mes: @mes) { |mes| SaidasDoMesQuery.call(mes: mes, categoria_id: @categoria_id, cartao_id: @cartao_id) }
    @comparacao_saldo = ComparacaoPeriodoQuery.call(mes: @mes) { |mes| SaldoDoMesQuery.call(mes: mes) }
  end

  # Entradas por Fonte, Entradas vs Saídas e Saldo Acumulado são gráficos de
  # tendência multi-mês (o "período anterior" já aparece como uma barra/
  # ponto adjacente no próprio gráfico) e nenhum tem uma noção de Categoria
  # ou Cartão (Renda não pertence a nenhum dos dois) — por isso ficam fora
  # do filtro de Categoria/Cartão, "quando aplicável" (ver AC do ticket #12).
  def carregar_graficos
    @grafico_saldo_restante_por_cartao = GraficoSaldoRestantePorCartaoQuery.call(cartao_id: @cartao_id)
    @grafico_gasto_por_categoria = GraficoGastoPorCategoriaQuery.call(mes: @mes, categoria_id: @categoria_id, cartao_id: @cartao_id)
    @grafico_entradas_por_fonte = GraficoEntradasPorFonteQuery.call
    @grafico_entradas_vs_saidas = GraficoEntradasVsSaidasQuery.call
    @grafico_saldo_acumulado = GraficoSaldoAcumuladoQuery.call
    @grafico_fatura_por_cartao = GraficoFaturaPorCartaoQuery.call(mes: @mes, cartao_id: @cartao_id)
  end

  def carregar_tabelas
    @central_de_obrigacoes = CentralDeObrigacoesQuery.call(mes: @mes)
    @proximos_vencimentos = ObrigacoesQuery.call
    @lancamentos = DespesasFiltradas.call(
      categoria_id: @categoria_id, cartao_id: @cartao_id, data_inicio: @mes, data_fim: @mes.end_of_month
    )
  end

  def carregar_opcoes_de_filtro
    @cartoes = Cartao.order(:nome)
    @categorias = Categoria.order(:nome)
  end
end
