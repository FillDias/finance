# Tabela de uma linha só — a Taxa CDI é global, não por Investimento
# (ver CONTEXT.md). #atual sempre retorna esse único registro, criando-o
# com valor zero na primeira vez que for consultado.
class TaxaCdi < ApplicationRecord
  validates :valor, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validate :registro_unico, on: :create

  def self.atual
    first_or_create!(valor: 0)
  rescue ActiveRecord::RecordNotUnique
    # Duas requisições concorrentes tentaram criar a linha ao mesmo tempo;
    # a que perdeu a corrida do índice único só precisa buscar a que ganhou.
    first!
  end

  private

  def registro_unico
    errors.add(:base, "Já existe uma Taxa CDI cadastrada") if TaxaCdi.exists?
  end
end
