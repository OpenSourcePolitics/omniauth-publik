# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "omniauth/publik/version"

Gem::Specification.new do |spec|
  spec.name = "omniauth-publik"
  spec.version = Omniauth::Publik::VERSION
  spec.authors = ["Armand Fardeau"]
  spec.email = ["armand@opensourcepolitics.eu"]

  spec.summary = "OmniAuth strategy for Publik"
  spec.description = "OmniAuth strategy for Publik"
  spec.homepage = "https://github.com/OpenSourcePolitics/omniauth-publik"
  spec.required_ruby_version = ">= 2.7"
  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "omniauth", "~> 2.0.4"
  spec.add_dependency "omniauth-oauth2", ">= 1.7.2", "< 2.0"
  spec.add_development_dependency "bundler", "~> 2.2.29"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-rspec"
  spec.metadata["rubygems_mfa_required"] = "true"
end
