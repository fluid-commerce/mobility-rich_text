# frozen_string_literal: true

require_relative "lib/mobility/rich_text/version"

Gem::Specification.new do |spec|
  spec.name = "mobility-rich_text"
  spec.version = Mobility::RichText::VERSION
  spec.authors = ["Mike Moore"]
  spec.email = ["mike.moore@fluid.app"]

  spec.summary = "Mobility plugin that wraps translated strings with ActionText::Content"
  spec.description = "A Mobility plugin that wraps string values from any backend with " \
                     "ActionText::Content, enabling rich text editing for translated content " \
                     "without separate ActionText storage. Works with all Mobility backends " \
                     "(KeyValue, Table, JSON, JSONB, Hstore) with no additional database tables required."
  spec.homepage = "https://github.com/fluid-commerce/mobility-rich_text"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/fluid-commerce/mobility-rich_text"
  spec.metadata["changelog_uri"] = "https://github.com/fluid-commerce/mobility-rich_text/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Runtime dependencies
  spec.add_dependency "actiontext", ">= 6.1"
  spec.add_dependency "mobility", ">= 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
