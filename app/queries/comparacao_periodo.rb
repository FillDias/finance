ComparacaoPeriodo = Struct.new(:atual, :anterior, keyword_init: true) do
  def delta
    atual - anterior
  end

  def percentual
    return nil if anterior.zero?

    delta.fdiv(anterior) * 100
  end
end
