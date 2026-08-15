# Menu de navegação no topo (dropdown), não sidebar lateral

O guia original (`docs/design-visual.md`) especificava uma sidebar fixa à esquerda para a navegação principal. Trocamos para um menu horizontal fixo no topo — marca à esquerda, link solo pro Painel (a tela mais visitada, fora de qualquer dropdown), e três grupos em dropdown (Lançamentos: Receitas/Despesas; Dívidas: Cartões/Empréstimos; Mais: Investimentos/Exportar) — inspirado numa referência de dashboard SaaS trazida pelo usuário. Cada dropdown mostra ícone + título por item (sem linha de descrição — os 7 itens já são autoexplicativos pelo nome) e fecha sozinho ao clicar fora ou de novo no item pai; não existe um botão de "recolher tudo", já que não é mais um menu lateral que expande/recolhe a página inteira.

Os tokens de cor da sidebar (`--sidebar-fundo`/`--sidebar-texto`) são reaproveitados na barra horizontal, sem criar paleta nova.

Nota: `docs/design-visual.md` (escrito antes desta ADR) descreve uma "Sidebar fixa à esquerda" na seção de referência visual. Essa seção foi superada por esta decisão — a navegação agora é uma barra horizontal com dropdowns, não uma sidebar. O restante do guia (paleta de cores, cards de KPI, gráficos) continua valendo.
