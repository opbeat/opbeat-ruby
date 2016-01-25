# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$:.unshift(lib) unless $:.include?(lib)
require 'opbeat/version'

Gem::Specification.new do |gem|
  gem.name             = "opbeat"
  gem.version          = Opbeat::VERSION
  gem.authors          = ["Mikkel Malmberg"]
  gem.email            = "support@opbeat.com"
  gem.summary          = "The official Opbeat Ruby client library"
  gem.homepage         = "https://github.com/opbeat/opbeat-ruby"
  gem.license          = "BSD-3-Clause"

  gem.files            = `git ls-files -z`.split("\x0")
  gem.require_paths    = ["lib"]
  gem.extra_rdoc_files = ["README.md", "LICENSE"]

  gem.add_dependency('activesupport', '>= 3.0.0')
end
