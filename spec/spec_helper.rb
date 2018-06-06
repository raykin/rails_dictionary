# copy and modify the test design of kaminari(a paginate gem for Rails3)
RAILS_ENV = 'test'
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rails'
require 'active_record'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'rails_dictionary'

require File.join(File.dirname(__FILE__), 'fake_app')

require 'rspec/rails'

$stdout = StringIO.new  # remove the noise output

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  # not work, must syntax error
  # config.expect_with(:rspec) { |c| c.syntax = :should }
  CreateAllTables.up unless ActiveRecord::Base.connection.table_exists? 'dict_types'
end

require 'byebug'
