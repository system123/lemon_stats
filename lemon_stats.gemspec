# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'lemon_stats/version'

Gem::Specification.new do |spec|
  spec.name          = "lemon_stats"
  spec.version       = LemonStats::VERSION
  spec.authors       = ["Lloyd Hughes"]
  spec.email         = ["hughes.lloyd@gmail.com"]

  spec.summary       = %q{Store your stats everywhere, simply.}
  spec.description   = %q{Simple gem to store and manage application statistics everywhere.}
  spec.homepage      = "http://www.github.com/System123/lemon_stats"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "redis"
  spec.add_dependency "json"
  spec.add_dependency "statsd-ruby"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
