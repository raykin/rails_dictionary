require 'bundler'
Bundler::GemHelper.install_tasks

task :default => [:test]

desc "Running Test"
task :test do
  Dir.glob('./test/**/*_test.rb') { |f| require f }
end
