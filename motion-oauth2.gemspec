# -*- encoding: utf-8 -*-
require File.expand_path("../lib/oauth2/version", __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "motion-oauth2"
  spec.version       = OAuth2::Version
  spec.authors       = ["Brian Pattison", "Michael Bleigh", "Erik Michaels-Ober"]
  spec.email         = ["brian@brianpattison.com", "michael@intridea.com", "sferik@gmail.com"]
  spec.description   = "A RubyMotion wrapper for the OAuth 2.0 protocol built with a similar style to the original OAuth spec."
  spec.summary       = "A RubyMotion wrapper for the OAuth 2.0 protocol."
  spec.homepage      = "https://github.com/motionauth/motion-oauth2"
  spec.license       = "MIT"

  files = []
  files << "README.md"
  files.concat(Dir.glob("lib/**/*.rb"))
  spec.files         = files
  spec.executables   = spec.files.grep(%r{^bin/}) {|f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "motion-cocoapods", "~> 1.7"
  spec.add_dependency "motion-support", "~> 0.2"
  spec.add_development_dependency "guard", "~> 2.6.1"
  spec.add_development_dependency "guard-motion", "~> 0.1"
  spec.add_development_dependency "motion_print", "~> 0.0"
  spec.add_development_dependency "motion-redgreen", "~> 1.0"
  spec.add_development_dependency "RackMotion", "~> 0.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "terminal-notifier-guard", "~> 1.6"
  spec.add_development_dependency "webstub"
end
