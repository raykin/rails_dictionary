source "https://rubygems.org"

ruby '> 3.3'

# Specify your gem's dependencies in rails_dictionary.gemspec
gemspec

group :development,:test do
  rails_version = ENV.fetch('RAILS_VERSION', nil)
  if rails_version
    gem 'rails', "~> #{rails_version}.0"
  else
    gem 'rails', '< 9.0'
  end
  gem "rspec-rails", '< 9'
  gem 'sqlite3'
end
