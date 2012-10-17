# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack-cachely/version'

Gem::Specification.new do |gem|
  gem.name          = "rack-cachely"
  gem.version       = Rack::Cachely::VERSION
  gem.authors       = ["Mark Bates"]
  gem.email         = ["mark@markbates.com"]
  gem.description   = %q{Rack middleware for interfacing with the Cachely page caching service.}
  gem.summary       = %q{Rack middleware for interfacing with the Cachely page caching service.}
  gem.homepage      = "http://www.cachelyapp.com"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency("rack")
end
