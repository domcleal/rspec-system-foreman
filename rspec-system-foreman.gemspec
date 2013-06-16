# -*- encoding: utf-8 -*-
Gem::Specification.new do |s|
  # Metadata
  s.name        = "rspec-system-foreman"
  s.version     = "0.1.0"
  s.authors     = ["Dominic Cleal"]
  s.email       = ["dcleal@redhat.com"]
  s.homepage    = "https://github.com/domcleal/rspec-system-foreman"
  s.summary     = "Foreman rspec-system plugin"

  # Manifest
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*_spec.rb`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib", "resources"]

  # Dependencies
  s.required_ruby_version = '>= 1.8.7'
  s.add_runtime_dependency "rspec-system", '~> 2.0'
  s.add_runtime_dependency "rspec-system-puppet", '~> 2.0'
end
