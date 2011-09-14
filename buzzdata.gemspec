# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "buzzdata/version"

Gem::Specification.new do |s|
  s.name        = "buzzdata"
  s.version     = BuzzData::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["BuzzData"]
  s.email       = ["support@buzzdata.com"]
  s.homepage    = "http://buzzdata.com/"
  s.summary     = %q{Ruby client for the BuzzData API}

  s.rubyforge_project = "buzzdata"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency('rest-client', '~> 1.6.7')
  s.add_development_dependency('rspec', '~> 2.6.0')
end
