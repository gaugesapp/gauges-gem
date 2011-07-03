# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "gauges/version"

Gem::Specification.new do |s|
  s.name        = "gauges"
  s.version     = Gauges::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['John Nunemaker']
  s.email       = ['nunemaker@gmail.com']
  s.homepage    = ""
  s.summary     = %q{Simple access to Gaug.es API}
  s.description = %q{Simple access to Gaug.es API}

  s.add_dependency('httparty', '~> 0.7.8')

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
