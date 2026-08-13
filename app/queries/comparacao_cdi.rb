ComparacaoCdi = Struct.new(:investimento, :taxa_anualizada, :taxa_cdi, keyword_init: true) do
  def diferenca
    taxa_anualizada - taxa_cdi
  end

  def acima_do_cdi?
    taxa_anualizada >= taxa_cdi
  end
end
