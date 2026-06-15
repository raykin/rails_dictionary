# Scenario: the app boots while the dict_types table does NOT exist yet
# (e.g. before the first migration). This used to leave the gem permanently
# broken. It must boot without raising, and recover once data appears.

require_relative "support"

define_models
build_and_initialize_app # to_prepare runs against an empty DB -> must not raise

assert !Dictionary.respond_to?(:country),
       "no lookup methods exist when the table is missing at boot"

create_dict_tables
DictType.create!(name: "country") # runtime write -> after_save hook regenerates

assert Dictionary.respond_to?(:country),
       "lookup method appears after a DictType is created at runtime"

puts "OK empty_boot_recovers"
