# Associa todo registro existente (hoje, 100% pertence ao Fill) ao Perfil
# "Fill", e garante que o Perfil "Fernanda" exista, vazio. Ver ADR 0007.
#
# Por padrão roda em modo dry-run: lista quantos registros seriam
# associados em cada tabela, sem salvar nada.
# Pra aplicar de verdade:
#   APLICAR=1 bin/rails runner db/scripts/associar_perfil_aos_dados.rb
#
# Dry-run (padrão):
#   bin/rails runner db/scripts/associar_perfil_aos_dados.rb

MODELS = [
  Renda, Despesa, Credor, Cartao, SaldoHerdado, FaturaPagamento,
  Compra, Emprestimo, Parcelamento, Parcela, Investimento, Aporte
].freeze

aplicar = ENV["APLICAR"] == "1"

fill = Perfil.find_or_create_by!(nome: "Fill")
fernanda = Perfil.find_or_create_by!(nome: "Fernanda")

puts "Modo: #{aplicar ? "APLICANDO" : "DRY-RUN (nada foi salvo)"}"
puts "Perfil \"Fill\" (##{fill.id}). Perfil \"Fernanda\" (##{fernanda.id}), sem dados."
puts

ActiveRecord::Base.transaction do
  MODELS.each do |modelo|
    # .unscoped: default_scope filtraria por Current.perfil, que não existe
    # fora de uma request — sem isso não veríamos os registros órfãos que
    # este script existe pra corrigir.
    sem_perfil = modelo.unscoped.where(perfil_id: nil)
    quantidade = sem_perfil.count

    sem_perfil.update_all(perfil_id: fill.id) if aplicar

    puts "#{modelo.name.ljust(15)} #{quantidade} registro(s) #{aplicar ? "associados" : "seriam associados"} ao Fill"
  end

  raise ActiveRecord::Rollback unless aplicar
end
