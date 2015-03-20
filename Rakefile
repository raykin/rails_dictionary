require 'bundler'
Bundler::GemHelper.install_tasks

task :default => [:test]

desc "Running Test"
task :test do
  system 'ruby test/rails_dictionary_test.rb'
  system 'ruby test/acts_as_consumer_test.rb'
  system 'ruby test/lookup_test.rb'
end
