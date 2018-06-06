# database
ActiveRecord::Base.configurations = {'test' => {:adapter => 'sqlite3', :database => ':memory:'}}

if ActiveRecord::VERSION::MAJOR >= 5
  ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')
else
  ActiveRecord::Base.establish_connection(:test)
end

# config
app = Class.new(Rails::Application)
app.config.active_support.deprecation = :log
app.config.eager_load = false
app.initialize!

# models
class DictType < ActiveRecord::Base
  acts_as_dict_type
end

class Dictionary < ActiveRecord::Base
  acts_as_dictionary
end

class Student < ActiveRecord::Base
end

#migrations
class CreateAllTables < ActiveRecord::VERSION::MAJOR >= 5 ? ActiveRecord::Migration[5.0] : ActiveRecord::Migration
  def self.up
    create_table(:dict_types) {|t| t.string :name}
    create_table(:dictionaries) {|t| t.string :name_en; t.string :name_zh ; t.string :name_fr ; t.integer :dict_type_id}
    create_table(:students) {|t| t.string :email; t.integer :city; t.integer :school}
  end

  def self.down
    drop_table :dict_types
    drop_table :dictionaries
    drop_table :students
  end
end
