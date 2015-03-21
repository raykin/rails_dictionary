# copy and modify the test design of kaminari(a paginate gem for Rails3)
RAILS_ENV = 'test'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'byebug'
require 'rack/test'
require 'rails'
require 'active_record'
require 'rails_dictionary'

ActiveRecord::Migration.verbose = false

require File.join(File.dirname(__FILE__), 'fake_app')

CreateAllTables.up unless ActiveRecord::Base.connection.table_exists? 'dictionaries'

Student.serialize :major_array, Array
Student.serialize :majors, Array

require 'minitest/autorun'
require 'database_cleaner'

DatabaseCleaner.strategy = :truncation

class TestSupporter < Minitest::Test
  def setup
    DatabaseCleaner.clean
  end

  def prepare_city_data
    [
     Dictionary.create!(name: 'beijing', type: 'Dictionary::City'),
     Dictionary.create!(name: 'shanghai', type: 'Dictionary::City')
    ]
  end
end
