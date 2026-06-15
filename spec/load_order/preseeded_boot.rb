# Scenario: the dict_types are already seeded BEFORE the app boots (the normal
# production case). Seeding here uses insert, which skips callbacks, so the
# after_save hook never fires. The lookup methods must therefore be generated
# by the Railtie's boot-time hook, with zero runtime writes.

require_relative "support"

define_models
create_dict_tables
DictType.insert({ name: "country" }) # seeded without firing callbacks

build_and_initialize_app # to_prepare -> RailsDictionary.load_dict_methods

assert Dictionary.respond_to?(:country),
       "lookup method is generated at boot from pre-seeded data"

Dictionary.create!(name_en: "France", dict_type_id: DictType.first.id)

assert Dictionary.country.map(&:name_en) == ["France"],
       "lookup returns seeded rows without any DictType runtime write"

puts "OK preseeded_boot"
