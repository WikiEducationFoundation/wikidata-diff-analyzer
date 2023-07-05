# frozen_string_literal: true

require_relative "lib/wikidata/diff/analyzer/version"

Gem::Specification.new do |spec|
  spec.name = "wikidata-diff-analyzer"
  spec.version = Wikidata::Diff::Analyzer::VERSION
  spec.authors = ["Sulagna Saha"]
  spec.email = ["saha23s@mtholyoke.edu"]

  spec.summary = "A Ruby gem for analyzing diffs between Wikidata items."
  spec.description = "This gem provides tools for analyzing diffs between Wikidata items, including retrieving the JSON representation of an item for a specific revision."
  spec.homepage = "https://github.com/WikiEducationFoundation/wikidata-diff-analyzer"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/WikiEducationFoundation/wikidata-diff-analyzer"
  spec.metadata["changelog_uri"] = "https://github.com/WikiEducationFoundation/wikidata-diff-analyzer/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.files.reject! { |f| File.extname(f) == '.gem' }

  # Adding the dependencies
  spec.add_dependency 'json', '~> 2.1'
end