# frozen_string_literal: true

require_relative "codeowners_validator/version"
require_relative "codeowners_validator/parser"
require_relative "codeowners_validator/checkers/duplicate_checker"
require_relative "codeowners_validator/checkers/ghost_pattern_checker"
require_relative "codeowners_validator/checkers/uncovered_file_checker"
require_relative "codeowners_validator/cli/duplicate_cli"
require_relative "codeowners_validator/cli/ghost_cli"
require_relative "codeowners_validator/cli/uncovered_cli"
require_relative "codeowners_validator/cli/main_cli"
