# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'attribute_changer/version'

Gem::Specification.new do |spec|
  spec.name          = "attribute_changer"
  spec.version       = AttributeChanger::VERSION
  spec.authors       = ["Zbigniew Humeniuk"]
  spec.email         = ["zbigniew.humeniuk@gmail.com"]
  spec.description   = %q{Allows step change for attributes.}
  spec.summary       = %q{Allows step change for attributes.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'activesupport', '>= 3.0.0'
  spec.add_dependency 'activerecord', '>= 3.0.0'

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.13.0"
  spec.add_development_dependency "activemodel", "~> 3.2.13"
  spec.add_development_dependency "sqlite3", "~> 1.3.7"
  spec.add_development_dependency 'database_cleaner', '~> 0.9.1'
  spec.add_development_dependency 'factory_girl', '~> 4.2.0'
end
