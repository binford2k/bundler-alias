
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "bundler/alias/version"

Gem::Specification.new do |spec|
  spec.name          = "bundler-alias"
  spec.version       = Bundler::Alias::VERSION
  spec.authors       = ["binford2k"]
  spec.email         = ["binford2k@overlookinfratech.com"]

  spec.summary       = "Alias one gem for another when using Bundler"
  spec.description   = "Select between multiple more or less equivalent gem implementations without requiring upstream accommodations."
  spec.homepage      = 'https://overlookinfratech.com'
  spec.license       = "GPL-3.0"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.require_paths = ["lib"]

  spec.description       = <<-DESC
  This plugin allow you to select between multiple more or less equivalent gem
  implementations without requiring upstream accommodations. This is useful,
  for example, when a defunct project is forked to keep it alive, but the
  ecosystem hasn't caught up and updated all the dependencies yet.
  DESC
end
