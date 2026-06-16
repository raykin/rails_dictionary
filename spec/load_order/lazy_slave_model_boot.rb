# Scenario: DictType is loaded and seeded BEFORE the Dictionary model is ever
# referenced (mirrors a host app whose seed/fixture file writes dict_types
# first, with eager_load off so the slave model autoloads lazily). The
# after_save hook fires reload_dict_methods while the Dictionary model is not
# yet registered, so it must still work once Dictionary is finally loaded.

require_relative "support"

# Only DictType exists at boot; Dictionary is NOT defined/registered yet.
Object.const_set(:DictType, Class.new(ActiveRecord::Base))
DictType.class_eval { acts_as_dict_type }

create_dict_tables
build_and_initialize_app # to_prepare runs; Dictionary not registered yet

DictType.create!(name: "country") # after_save -> reload_dict_methods, empty registry

# Host app references the slave model for the first time here.
Object.const_set(:Dictionary, Class.new(ActiveRecord::Base))
Dictionary.class_eval { acts_as_dictionary }

assert Dictionary.respond_to?(:country),
       "lookup method exists when the slave model is loaded after seeding"

puts "OK lazy_slave_model_boot"
