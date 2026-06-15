require 'bundler'
Bundler::GemHelper.install_tasks

task :default => [:test, :load_order]

desc "Running Test"
task :test do
  # system "ruby -I . test/rails_dictionary_test.rb " # used with version 0.0.8 or before it
  sh "bundle exec rspec spec/rails_dictionary_spec.rb"
end

desc "Run isolated load-order scenarios (each in its own process)"
task :load_order do
  Dir[File.expand_path("spec/load_order/*_boot*.rb", __dir__)].sort.each do |script|
    sh "bundle exec ruby #{script}"
  end
end
