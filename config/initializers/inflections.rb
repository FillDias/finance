# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.plural /^(ox)$/i, "\\1en"
#   inflect.singular /^(ox)en/i, "\\1"
#   inflect.irregular "person", "people"
#   inflect.uncountable %w( fish sheep )
# end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym "RESTful"
# end

# Rails' default English inflector treats words ending in "-ia" as the
# plural of an "-ium" word (criteria/criterion, media/medium), which
# wrongly singularizes our Portuguese "categoria" to "categorium".
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.irregular "categoria", "categorias"
  inflect.irregular "credor", "credores"
  inflect.irregular "cartao", "cartoes"
  inflect.irregular "saldo_herdado", "saldos_herdados"
  inflect.irregular "tipo_investimento", "tipos_investimento"
  inflect.irregular "taxa_cdi", "taxas_cdi"
end
