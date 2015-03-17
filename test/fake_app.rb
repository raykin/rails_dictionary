# database
ActiveRecord::Base.configurations = {'test' => {:adapter => 'sqlite3', :database => ':memory:'}}
ActiveRecord::Base.establish_connection(:test)

# config
app = Class.new(Rails::Application)
app.config.active_support.deprecation = :log
app.config.eager_load = false
app.initialize!

class Dictionary < ActiveRecord::Base
  acts_as_dictionary
end

class Student < ActiveRecord::Base
end

#migrations
class CreateAllTables < ActiveRecord::Migration
  def self.up
    create_table(:dictionaries) {|t| t.string :name; t.string :type}
    create_table(:students) {|t| t.string :email; t.integer :city_id; t.integer :school_id}
  end

  def self.down
    drop_table :dictionaries
    drop_table :students
  end
end
