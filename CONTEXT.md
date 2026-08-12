# Fluxo de Caixa e Dívidas

Dashboard financeiro pessoal para um único usuário controlar entradas e saídas, com foco em visibilidade sobre dívidas de cartão de crédito parcelado e empréstimos/financiamentos de parcela fixa — sem reconciliação bancária ou análise de juros.

## Language

### Dívida e Obrigação

**Obrigação**:
Conceito guarda-chuva para qualquer valor a pagar com vencimento e status (pendente, paga, atrasada), de quatro origens possíveis: Saldo Herdado, Parcela de Compra, Parcela de Empréstimo, ou Despesa Fixa. Sustenta o Painel (KPIs e próximos vencimentos) sem precisar de uma tela dedicada que junte cartões e empréstimos manualmente. Despesa Fixa é a única origem sem estado "paga" persistido (ver Despesa) — nela, `data` é tratada como o vencimento, e o status é sempre pendente ou atrasada, nunca paga.
_Avoid_: Dívida (usar Obrigação como termo técnico único)

**Credor**:
Banco ou financeira que emite um ou mais Cartões e/ou concede um ou mais Empréstimos.
_Avoid_: Banco, instituição

### Cartão de crédito

**Cartão**:
Meio de pagamento emitido por um Credor. Tem limite total, dia de fechamento (define em qual mês uma Compra cai) e dia de vencimento. Cada cartão tem sua própria data de corte.
_Avoid_: Cartão de crédito (usar Cartão)

**Data de corte**:
Data própria de cada Cartão a partir da qual compras passam a ser lançadas individualmente (como Compra). Antes dela, a dívida do cartão é representada só como Saldo Herdado. É uma decisão de importação de histórico, não uma data do ciclo de fatura do banco.
_Avoid_: Data de início, ponto de corte

**Saldo Herdado**:
Valor total conhecido da fatura de um Cartão num mês anterior à data de corte, sem detalhamento de item por item. Existe apenas para meses dentro do histórico importado. Pode ser quitado antes do previsto, registrando o valor efetivamente pago e a data (pode ser menor que o valor previsto, por desconto de negociação).
_Avoid_: Dívida herdada, saldo antigo

**Compra**:
Lançamento feito num Cartão a partir da data de corte, à vista ou parcelado. Toda Compra gera pelo menos uma Parcela (à vista = uma parcela única; parcelada = N parcelas). Cai na Fatura do mês determinado pelo dia de fechamento do cartão, não pelo mês calendário da compra.
_Avoid_: Transação, lançamento de cartão

**Fatura**:
Projeção calculada de quanto um Cartão vai cobrar num mês: Saldo Herdado daquele mês (se existir) somado às Parcelas de Compras que caem naquele mês, respeitando o dia de fechamento do cartão. Não é uma entidade com ciclo de vida (não tem estados "aberta/fechada"); tem apenas um registro opcional de pagamento (data e valor pago) por Cartão e mês.
_Avoid_: Fatura fechada, invoice

**Saldo restante (de um Cartão)**:
Soma do Saldo Herdado ainda em aberto (meses futuros dentro do histórico herdado, não quitados) com as Parcelas de Compras desse cartão ainda pendentes ou atrasadas.
_Avoid_: Dívida total, saldo devedor

**Utilização do limite**:
Percentual do limite de um Cartão comprometido: Saldo restante dividido pelo limite total.
_Avoid_: Limite usado

### Empréstimo e Parcela

**Empréstimo**:
Dívida de parcela fixa concedida por um Credor, com cronograma completo de Parcelas cadastrado de uma vez, desde o início. Financiamento é tratado como sinônimo — mesma mecânica, sem distinção jurídica no sistema.
_Avoid_: Financiamento (usar Empréstimo como termo técnico único, mas aceitar como sinônimo na interface)

**Parcela**:
Obrigação de valor e data de vencimento fixos, originada de uma Compra parcelada de Cartão ou de um Empréstimo. Não tem detalhamento de juros/principal — apenas o valor total já definido no contrato ou na compra. Quando a divisão de um valor total não é exata, o ajuste de centavos vai na última parcela.
_Avoid_: Prestação

### Fluxo de caixa

O fluxo de caixa tem três blocos independentes — Renda, Despesa e Aporte (ver Investimentos) — nunca somados numa única métrica de "saída". Aporte sai do caixa mas não é Despesa.

**Renda**:
Lançamento de entrada de dinheiro: valor, data e categoria/fonte (ex.: Salário, Freela, Venda avulsa) como uma tag simples. Lançada manualmente a cada ocorrência, mesmo quando recorrente (ex.: salário mensal) — sem automação no MVP.
_Avoid_: Entrada, receita

**Despesa**:
Lançamento de saída de dinheiro, classificado como Fixa ou Variável (rótulo, não uma diferença estrutural) e com uma forma de pagamento (Cartão específico, Débito, Boleto, PIX ou Dinheiro). Quando a forma de pagamento é um Cartão, a Despesa é a mesma linha que a Compra lançada nesse cartão — nunca duas linhas separadas. Despesa Fixa tem uma data de vencimento própria (dia do mês) e aparece nos próximos vencimentos. Ao contrário de Saldo Herdado e Parcela, Despesa não tem campo de pagamento — é lançada como um fato já resolvido. Como Obrigação, seu `data` é o vencimento e seu status nunca é "paga": some da lista de próximos vencimentos quando lançada, ficando só no histórico de Despesas.
_Avoid_: Gasto, saída

**Categoria**:
Rótulo compartilhado entre Despesas (fixas e variáveis) e Compras de cartão, usado para filtro e análise no Painel.
_Avoid_: Tag (reservado para fonte de Renda)

### Investimentos

**Investimento**:
Uma posição específica de investimento (ex.: um CDB no Nubank): tipo, instituição (texto livre), taxa de rendimento esperado (% ao mês ou % ao ano) e status (ativo ou resgatado), com data de vencimento opcional. Recebe um ou mais Aportes ao longo do tempo. É dinheiro que sai do fluxo de caixa mas vira patrimônio — nunca é contado como Despesa.
_Avoid_: Aplicação, ativo

**Tipo de Investimento**:
Rótulo compartilhado entre Investimentos (ex.: CDB, Tesouro Direto, Poupança), cadastrável pelo próprio usuário sem precisar de deploy — mesmo padrão de Categoria, mas um conceito próprio (não reaproveita Categoria de Despesa). Semeado com um conjunto inicial: CDB, CDI, Poupança, Tesouro Direto, Ações, Fundos Imobiliários, Reserva de Emergência, Outro.
_Avoid_: Categoria de investimento

**Aporte**:
Lançamento de um valor colocado num Investimento, numa data específica. Um Investimento recebe vários Aportes ao longo do tempo. Nunca conta como Despesa — tem seu próprio bloco no fluxo de caixa.
_Avoid_: Contribuição, depósito

**Resgate**:
Encerramento total de um Investimento: muda o status para resgatado e registra o valor efetivamente resgatado (pode diferir da soma aportada, pelo rendimento) e a data do resgate. Não existe resgate parcial — a posição fecha por inteiro.
_Avoid_: Saque

**Taxa CDI**:
Taxa de referência do mercado, cadastrada manualmente e de forma global — um valor só vale para todo o sistema, não por Investimento. Usada para uma comparação simples entre o rendimento esperado de um Investimento atrelado a CDI e o CDI vigente.
_Avoid_: Taxa de referência

## Fora de escopo (decisões deliberadas)

- Sem reconciliação com extrato bancário nem modelagem de saldo de conta corrente — o sistema rastreia apenas Obrigações (o que se deve) e Renda (o que entra).
- Sem detalhamento de juros/amortização em Parcelas de Empréstimo — o valor da parcela já vem pronto do contrato.
- Sem template de recorrência automática para Despesa Fixa ou Renda no MVP — lançamento manual a cada ocorrência (adiado para fase 2).
- Sem tela "Central de Dívidas" separada — a visão unificada por Obrigação vive no Painel; Cartões e Empréstimos têm telas de detalhe próprias.
- Sem resgate parcial de Investimento — só resgate total, fechando a posição inteira.
- Sem cálculo de juros compostos na projeção de rendimento de Investimento — estimativa simples (valor × taxa do período), sem compor.
- Sem atualização automática da Taxa CDI — cadastro manual por enquanto; automação é melhoria futura.
