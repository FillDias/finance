module ValidarParPreenchido
  extend ActiveSupport::Concern

  class_methods do
    # Garante que dois campos sejam preenchidos juntos, ou nenhum dos dois —
    # o padrão usado por "quitação antecipada"/"resgate", onde um valor e sua
    # data só fazem sentido juntos.
    def validar_par_preenchido(campo_a, campo_b)
      validate do
        valor_a = public_send(campo_a)
        valor_b = public_send(campo_b)
        next if valor_a.present? == valor_b.present?

        nome_a = self.class.human_attribute_name(campo_a)
        nome_b = self.class.human_attribute_name(campo_b).downcase
        errors.add(:base, "#{nome_a} e #{nome_b} devem ser preenchidos juntos")
      end
    end
  end
end
