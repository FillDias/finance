# Fora de escopo: detalhamento de juros e reconciliação bancária

O objetivo do app é fluxo de caixa e visibilidade de dívida, não análise de custo financeiro nem contabilidade. Decidimos deliberadamente que Parcelas (de Compra ou de Empréstimo) não têm detalhamento de juros/principal — apenas o valor total já definido no contrato ou na compra — e que o sistema não modela saldo de conta corrente nem tenta reconciliar lançamentos com o extrato bancário real. O sistema rastreia apenas Obrigações (o que se deve) e Renda (o que entra).

Alternativa rejeitada: modelar tabela de amortização por Parcela de Empréstimo (juros vs principal) e/ou saldo de conta corrente com reconciliação de extrato — ambos aumentariam bastante a complexidade do modelo de dados sem servir ao objetivo real (saber quanto vai vencer e quando), que já é resolvido com valor + data.
