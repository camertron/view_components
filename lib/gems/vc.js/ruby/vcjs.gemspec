# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "vcjs/version"

Gem::Specification.new do |spec|
  spec.name          = "vcjs"
  spec.version       = Vcjs::VERSION
  spec.authors       = ["GitHub Open Source"]
  spec.email         = ["opensource+vcjs@github.com"]

  spec.summary       = "Rack middleware for rendering View Components with JavaScript."
  spec.homepage      = "https://github.com/primer/vc.js"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = Dir["CHANGELOG.md", "LICENSE.txt", "README.md", "lib/**/*"]
  spec.require_paths = ["lib"]
end
