# frozen_string_literal: true

# Steepfile - Configuration for Steep type checker
#
# Run type checking with: bundle exec steep check

target :lib do
  # Check Ruby files in lib/
  check "lib"

  # Load type signatures from sig/
  signature "sig"

  # Configure strictness (lenient for now, can be made stricter later)
  # Options: strict, default, lenient, silent
  configure_code_diagnostics(Steep::Diagnostic::Ruby.lenient)
end
