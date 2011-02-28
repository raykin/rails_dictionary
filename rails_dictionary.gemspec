# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "dictionary/version"

Gem::Specification.new do |s|
  s.name        = "rails_dictionary"
  s.version     = Dictionary::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["raykin"]
  s.email       = ["raykincoldxiao@campus.com"]
  s.homepage    = "https://github.com/raykin/dictionary"
  s.summary     = %q{dictionary data for application}
  s.description = %q{mapping static data of web application to Dictionary class}

  s.rubyforge_project = "rails_dictionary"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
