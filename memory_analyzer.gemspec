# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'memory_analyzer/version'

Gem::Specification.new do |spec|
  spec.name          = "memory_analyzer"
  spec.version       = MemoryAnalyzer::VERSION
  spec.authors       = ["Jason Frey"]
  spec.email         = ["fryguy9@gmail.com"]

  spec.summary       = %q{Ruby heap analyzer}
  spec.description   = %q{Ruby heap analyzer}
  spec.homepage      = "http://github.com/Fryguy/memory_analyzer"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = ["memory_analyzer"]
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"

  spec.add_dependency 'ruby-progressbar'
end
