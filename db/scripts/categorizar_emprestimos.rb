# Backfill de categoria_id nos Emprestimos existentes, necessário antes da
# migration ChangeCategoriaNullFalseOnEmprestimos (que exige o campo
# preenchido em todo mundo). Cria a categoria "Financiamento" se não
# existir e categoriza qualquer Emprestimo ainda sem categoria com ela —
# ajuste manualmente depois (ex.: via rails console) se algum empréstimo
# específico merecer uma categoria diferente (ex.: consignado vs.
# financiamento de veículo).
#
# Rodar com: bin/rails runner db/scripts/categorizar_emprestimos.rb

categoria = Categoria.find_or_create_by!(nome: "Financiamento")
atualizados = Emprestimo.where(categoria_id: nil).update_all(categoria_id: categoria.id)

puts "Categoria \"Financiamento\" (##{categoria.id}). Empréstimos categorizados agora: #{atualizados}."
puts "Empréstimos ainda sem categoria: #{Emprestimo.where(categoria_id: nil).count}."
