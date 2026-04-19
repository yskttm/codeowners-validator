# frozen_string_literal: true

require_relative "lib/codeowners_validator/version"

Gem::Specification.new do |spec|
  spec.name = "codeowners-validator"
  spec.version = CodeownersValidator::VERSION
  spec.authors = ["yskttm"]
  spec.email = []

  spec.summary = "A CLI tool for validating GitHub CODEOWNERS files"
  spec.homepage = "https://github.com/yskttm/codeowners-validator"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.files = Dir["lib/**/*.rb", "bin/codeowners-validator", "LICENSE", "README.md"]
  spec.executables = ["codeowners-validator"]
  spec.require_paths = ["lib"]
end
