# frozen_string_literal: true

require_relative "lib/viewchars/version"

Gem::Specification.new do |spec|
  spec.name          = "viewchars"
  spec.version       = Viewchars::VERSION
  spec.authors       = ["J. R. Schmid"]
  spec.email         = ["jrs+git@weitnahbei.de"]

  spec.summary       = "Little command line tool to help find the way through the character jungle ... or jumble"
  spec.description   = "See what codepoints are hiding behind a string, or what string might be hiding behind a list of numbers."
  spec.homepage      = "https://github.com/sixtyfive/viewchars"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/sixtyfive/viewchars.git"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'slop'
  spec.add_dependency 'colorize'
  spec.add_dependency 'unicode-name'
  spec.add_dependency 'tty-table'

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
