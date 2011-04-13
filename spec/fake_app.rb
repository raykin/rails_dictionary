require 'active_record'
require 'action_controller/railtie'
require 'action_view/railtie'

# database
ActiveRecord::Base.configurations = {'test' => {:adapter => 'sqlite3', :database => ':memory:'}}
ActiveRecord::Base.establish_connection('test')

# config
app = Class.new(Rails::Application)
app.config.active_support.deprecation = :log
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
class CreateAllTables < ActiveRecord::Migration
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
