# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'terjira/version'

Gem::Specification.new do |spec|
  spec.name          = "terjira"
  spec.version       = Terjira::VERSION
  spec.authors       = ["keepcosmos"]
  spec.email         = ["keepcosmos@gmail.com"]

  spec.summary       = "TEST DESCRIPTION"
  spec.description   = "TEST DESCRIPTION"
  spec.homepage      = "https://www.jaehyunshin.me"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TEST: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|dev)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "thor", "~> 0.19"
  spec.add_dependency "jira-ruby", "~> 1.1"
  spec.add_dependency "activesupport", "~> 4.0.0"

  # spec.add_dependency "tty"
  spec.add_dependency "tty-table"
  spec.add_dependency "tty-prompt"
  spec.add_dependency "tty-spinner"
  spec.add_dependency "pastel"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "pry"
end
