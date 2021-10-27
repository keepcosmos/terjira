# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'terjira/version'

Gem::Specification.new do |spec|
  spec.name          = "terjira"
  spec.version       = Terjira::VERSION
  spec.authors       = ["Jaehyun Shin"]
  spec.email         = ["keepcosmos@gmail.com"]

  spec.summary       = "Terjira is interactive command line application for Jira"
  spec.description   = "Terjira is interactive and easy to use command line interface (or Application) for Jira.\nYou do not need to remember resource key or id. Terjira suggests with interactive prompt."
  spec.homepage      = "https://github.com/keepcosmos/terjira"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|dev)/}) }
  spec.bindir        = "bin"
  spec.executables   = ["bin/jira"].map { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", "~> 1.0"
  spec.add_dependency "jira-ruby", "~> 2.1"
  spec.add_dependency "activesupport", ">= 4"

  spec.add_dependency "tty-table", ">= 0.12"
  spec.add_dependency "tty-prompt", ">= 0.23"
  spec.add_dependency "tty-spinner", ">= 0.9"

  spec.add_development_dependency "bundler", "~> 2.1"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.9"
  spec.add_development_dependency "simplecov", "~> 0"
  spec.add_development_dependency "pry", "~> 0.12.0"
end
