# Shared setup for the isolated load-order scripts. Each scenario runs in its
# OWN process so it can control what exists in the database at boot time —
# something the shared rspec suite (single process, tables already created)
# cannot exercise.

$LOAD_PATH.unshift(File.expand_path("../../../lib", __FILE__))

require "rails"
require "active_record"
require "action_controller/railtie"
require "rails_dictionary"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

def define_models
  # Assign the constant BEFORE running the macro so the class already has a
  # name when it registers itself (mirrors `class Dictionary < AR::Base`).
  Object.const_set(:DictType, Class.new(ActiveRecord::Base))
  DictType.class_eval { acts_as_dict_type }
  Object.const_set(:Dictionary, Class.new(ActiveRecord::Base))
  Dictionary.class_eval { acts_as_dictionary }
end

def create_dict_tables
  ActiveRecord::Schema.verbose = false
  ActiveRecord::Schema.define do
    create_table(:dict_types) { |t| t.string :name }
    create_table(:dictionaries) { |t| t.string :name_en; t.integer :dict_type_id }
  end
end

def build_and_initialize_app
  app = Class.new(Rails::Application)
  app.config.active_support.deprecation = :log
  app.config.eager_load = false
  app.initialize!
end

def assert(condition, message)
  raise "FAIL: #{message}" unless condition
end
