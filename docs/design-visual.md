# Guia de Design Visual — Dashboard Financeiro (estilo Power BI)

Cole este documento no Claude Code quando chegar na etapa de implementar o módulo de Painel/Dashboard — ou peça pra ele salvar como `docs/design-visual.md` e referenciar durante o `/implement`.

---

## Referência visual (descrição de um dashboard SaaS que uso como modelo)

O visual de referência tem esta estrutura:

- **Sidebar fixa à esquerda**, fundo azul-marinho bem escuro (quase preto-azulado), com um logotipo/ícone no topo, depois os itens de navegação em branco/cinza-claro, cada um com um ícone pequeno à esquerda do texto. O item ativo tem um fundo levemente mais claro que o resto da sidebar (um leve destaque, não uma cor totalmente diferente).
- **Área de conteúdo à direita**, fundo branco/cinza muito claro, organizada em **cards com cantos arredondados e sombra leve**, dispostos em grid (2 ou 3 colunas dependendo do tipo de gráfico).
- **Cabeçalho da página**: título grande à esquerda, e à direita alguns ícones pequenos de ação (ajuda "?", atualizar, filtro) — discretos, não botões grandes.
- **Cards de KPI** no topo: fundo branco ou cinza muito claro, com:
  - Um rótulo pequeno e discreto no topo (ex: "Revenue")
  - Um número grande e em negrito logo abaixo (o valor principal)
  - Uma **mini linha de tendência (sparkline)** ao lado do número — um gráfico de linha minúsculo, sem eixos, só mostrando a forma da tendência recente, com um ponto verde marcando o valor mais alto e um ponto vermelho marcando o mais baixo
  - Embaixo, comparação com período anterior em texto pequeno (ex: "PY: £9,28 Mi", "ΔPY: £8,68 Mi", "YoY%")
- **Gráfico de rosca (donut)**: usado para mostrar composição percentual de uma categoria (ex: "Revenue by Level_02" no exemplo) — fatias em tons de azul, do mais escuro (categoria dominante) ao mais claro, com % anotado do lado de fora de cada fatia por uma linha guia.
- **Gráfico de barras horizontais com gradiente**: barras que vão de azul claro (esquerda) para azul escuro (direita), ordenadas da maior pra menor, valor anotado no final de cada barra. Usado pra ranking (ex: "Revenue by Vendor's Name").
- **Gráfico de barras verticais com gradiente**: mesma lógica mas na vertical, gradiente de cima (claro) pra baixo (escuro), valor anotado acima de cada barra. Usado pra evolução temporal categórica (ex: "Gross Profit por Year", "Gross Profit por Quarter").
- **Gráfico de linha/área comparativo**: duas ou três séries sobrepostas (ex: "Gross Profit vs OPEX"), com uma anotação de seta mostrando a diferença/razão entre as duas séries no ponto final.
- **Gráfico de barras + linha combinado**: barras pro valor absoluto (ex: Revenue por ano) e uma linha fina sobreposta pra variação percentual, com o número da variação anotado acima de cada grupo.
- **Waterfall (cascata)**: usado pra mostrar acumulação/queda mês a mês até um total (ex: "Net Profit/Loss by Month") — barras vermelhas pra queda, barra roxa/escura pro total final, com uma seta vertical vermelha ligando o primeiro ao último valor e uma anotação "Max: -£1.291.050 (-819,97%)".
- **Tabela financeira**: cabeçalho com fundo azul-marinho escuro e texto branco. Linhas com fundo alternado (branco/cinza muito claro). Categorias-pai em negrito com fundo levemente mais escuro que os itens-filho (indentados). Coluna de variação com **texto colorido**: verde pra positivo, vermelho pra negativo — sem preencher a célula inteira, só o texto do número.

## Paleta de cores

| Uso | Cor |
|---|---|
| Fundo da sidebar | `#101B2D` (azul-marinho quase preto) |
| Texto/ícones da sidebar | `#E4E8F0` (quase branco) |
| Item ativo da sidebar | `#1C2A42` (leve destaque, mesma família) |
| Fundo da área de conteúdo | `#F4F6F9` (cinza muito claro) |
| Fundo dos cards | `#FFFFFF` |
| Gradiente das barras (claro → escuro) | de `#A9C4E8` até `#0B2E5C` |
| Positivo / entrada / verde | `#1E8E3E` |
| Negativo / saída / dívida / vermelho | `#C0392B` |
| Cabeçalho de tabela | `#101B2D` com texto `#FFFFFF` |
| Texto secundário/legendas | `#6B7280` (cinza médio) |

## Tipografia

- Fonte sans-serif moderna (ex: Inter, ou a fonte padrão do sistema) em todo o dashboard.
- Números de KPI: grandes (28–32px), peso bold (700).
- Rótulos acima dos números: pequenos (12px), peso normal, cor secundária.
- Títulos de card/gráfico: 14–16px, peso semi-bold (600), sempre no canto superior esquerdo do card.

---

## Gráficos específicos que preciso no MEU dashboard (mapeando pro meu domínio)

Adaptando esse estilo pros meus dados reais (Receitas, Despesas, Cartões, Empréstimos):

1. **KPI cards no topo** (com sparkline, como no modelo): Entradas do mês, Saídas do mês, Saldo do mês, Dívida Total (Obrigações em aberto).
2. **Gráfico de rosca — Dívida por Cartão**: composição da dívida total entre os cartões (Saldo Herdado + parcelas em aberto de cada um), fatias em gradiente de azul.
3. **Gráfico de barras horizontais com gradiente — Gasto por Categoria no mês**: ranking do maior pro menor gasto (ex: Mercado, Gasolina, Lazer, Contas fixas...), valor anotado no final de cada barra — este é o mais importante pra eu entender rápido onde o dinheiro está indo.
4. **Gráfico de barras verticais — Entradas mensais (Renda)**: uma barra por mês, mostrando o total de entradas, com a opção de segmentar por fonte (Salário/Freela/Venda) empilhado dentro da mesma barra em tons diferentes de verde/azul.
5. **Gráfico de linha/área comparativo — Entradas vs Saídas ao longo do tempo**: duas linhas sobrepostas (verde pra entrada, vermelha pra saída), últimos 6 meses + projeção dos próximos 3 (linha tracejada na parte projetada, pra deixar claro visualmente que é previsão).
6. **Waterfall — Saldo acumulado mês a mês**: mostrando como o saldo do mês vai subindo/descendo ao longo do ano, igual ao "Net Profit/Loss by Month" do modelo, com barras vermelhas nos meses negativos.
7. **Barras horizontais com gradiente — Fatura por Cartão (mês atual)**: ranking dos cartões pela fatura projetada do mês, pra eu ver rápido qual cartão está pesando mais.
8. **Tabela financeira estilo "Profit and Loss"**: aplicar esse mesmo visual (cabeçalho escuro, categorias em negrito, variação colorida) na tela de **Central de Obrigações/Vencimentos** — comparando "Previsto" (valor da parcela) vs "Pago" (quando houver registro de pagamento antecipado com valor diferente), com a variação em verde/vermelho.

## Observação técnica pro Claude Code

Chartkick sozinho (com Chart.js por baixo) dá conta da maioria dos gráficos acima, mas **duas coisas exigem configuração customizada de Chart.js puro** (não dá pra fazer só com a API simples do Chartkick):

- **Gradiente nas barras** (claro → escuro): precisa de um `CanvasGradient` configurado no dataset do Chart.js, não é uma opção pronta do Chartkick.
- **Sparkline dentro do KPI card**: um mini gráfico de linha sem eixos, sem grid, sem legenda, só a linha — vale usar `Chart.js` puro com `scales: { x: { display: false }, y: { display: false } }` num canvas pequeno dentro do próprio card, não um gráfico Chartkick de tamanho padrão.

Peça pra ele confirmar essa abordagem (Chartkick pros gráficos padrão + Chart.js customizado só nesses dois casos específicos) antes de implementar, pra não tentar forçar tudo dentro da API simplificada do Chartkick e perder o visual.
