# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'safebox/version'

Gem::Specification.new do |spec|
  spec.name          = "safebox"
  spec.version       = Safebox::VERSION
  spec.authors       = ["Jonas Nicklas", "Kim Burgestrand"]
  spec.email         = ["jonas@elabs.se", "kim@elabs.se"]

  spec.summary       = %q{Simple message encryption using RbNaCl}
  spec.homepage      = "https://github.com/elabs/safebox"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rbnacl", "~> 3.0"
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
end
