require 'bundler'
Bundler::GemHelper.install_tasks

task :default => [:test]

desc "Running Test"
task :test do
  # system "ruby -I . test/rails_dictionary_test.rb " # used with version 0.0.8 or before it
  system "rspec spec/rails_dictionary_spec.rb"
end
