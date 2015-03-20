# copy and modify the test design of kaminari(a paginate gem for Rails3)
RAILS_ENV = 'test'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'byebug'
require 'rack/test'
require 'rails'
require 'active_record'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'rails_dictionary'

ActiveRecord::Migration.verbose = false

require File.join(File.dirname(__FILE__), 'fake_app')

# $stdout = StringIO.new  # remove the noise output # looks like the create table noise

# RSpec.configure do |config|
#   config.use_transactional_fixtures = true
#   CreateAllTables.up unless ActiveRecord::Base.connection.table_exists? 'dict_types'
# end

CreateAllTables.up unless ActiveRecord::Base.connection.table_exists? 'dictionaries'

require 'minitest/autorun'

require 'database_cleaner'

DatabaseCleaner.strategy = :truncation

class TestSupporter < Minitest::Test
  def setup
    DatabaseCleaner.clean
  end
end
