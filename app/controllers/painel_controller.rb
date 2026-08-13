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

  private

  def mes_filtrado
    Date.parse(params[:mes]).beginning_of_month
  rescue ArgumentError, TypeError
    Date.current.beginning_of_month
  end

  def carregar_kpis
    @entradas_do_mes = EntradasDoMesQuery.call(mes: @mes)
    @saidas_do_mes = SaidasDoMesQuery.call(mes: @mes)
    @saldo_do_mes = SaldoDoMesQuery.call(mes: @mes)
    @divida_total = DividaTotalQuery.call

    @sparkline_entradas = GraficoSparklineEntradasQuery.call
    @sparkline_saidas = GraficoSparklineSaidasQuery.call
    @sparkline_saldo = GraficoSparklineSaldoQuery.call
    @sparkline_divida_total = GraficoSparklineDividaTotalQuery.call

    @comparacao_entradas = ComparacaoPeriodoQuery.call(mes: @mes) { |mes| EntradasDoMesQuery.call(mes: mes) }
    @comparacao_saidas = ComparacaoPeriodoQuery.call(mes: @mes) { |mes| SaidasDoMesQuery.call(mes: mes) }
    @comparacao_saldo = ComparacaoPeriodoQuery.call(mes: @mes) { |mes| SaldoDoMesQuery.call(mes: mes) }
  end

  def carregar_graficos
    @grafico_divida_por_cartao = GraficoDividaPorCartaoQuery.call
    @grafico_gasto_por_categoria = GraficoGastoPorCategoriaQuery.call(mes: @mes)
    @grafico_entradas_por_fonte = GraficoEntradasPorFonteQuery.call
    @grafico_entradas_vs_saidas = GraficoEntradasVsSaidasQuery.call
    @grafico_saldo_acumulado = GraficoSaldoAcumuladoQuery.call
    @grafico_fatura_por_cartao = GraficoFaturaPorCartaoQuery.call(mes: @mes)
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
