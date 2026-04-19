# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
bundle install
bundle exec rspec                                    # run all tests
bundle exec rspec spec/lib/foo_spec.rb               # single file
bundle exec rspec spec/lib/foo_spec.rb:20            # single example
bundle exec standardrb                               # lint
bundle exec standardrb --fix                         # auto-correct lint violations
```

CLI tool (requires a CODEOWNERS file as argument):

```bash
ruby bin/codeowners-validator duplicate CODEOWNERS
ruby bin/codeowners-validator ghost CODEOWNERS
ruby bin/codeowners-validator uncovered CODEOWNERS
```

## Architecture

Each subcommand follows the same pipeline pattern:

```
bin/codeowners-validator → MainCli → <*Cli> → Parser → <*Checker> → output / exit status
```

- **`lib/codeowners_validator.rb`** — top-level require that loads all components
- **`lib/codeowners_validator/parser.rb`** — parses CODEOWNERS lines into `CodeownersEntry` value objects (`Data.define`); skips blank lines and comment lines
- **`lib/codeowners_validator/cli/main_cli.rb`** — parses subcommand and delegates to the appropriate `*Cli` class
- **`lib/codeowners_validator/cli/duplicate_cli.rb`** — handles output and exit status for the `duplicate` subcommand
- **`lib/codeowners_validator/cli/ghost_cli.rb`** — handles output and exit status for the `ghost` subcommand
- **`lib/codeowners_validator/cli/uncovered_cli.rb`** — handles output and exit status for the `uncovered` subcommand
- **`lib/codeowners_validator/checkers/duplicate_checker.rb`** — groups entries by pattern, returns those with size > 1
- **`lib/codeowners_validator/checkers/ghost_pattern_checker.rb`** — checks each pattern against the filesystem (`Dir.glob` / `Dir.exist?`); takes `repo_root` as the base path
- **`lib/codeowners_validator/checkers/uncovered_file_checker.rb`** — enumerates all files under `repo_root` and checks each against CODEOWNERS patterns via `File.fnmatch`; excludes `.git/` by default

### Pattern matching notes (`uncovered_file_checker.rb`)

`File::FNM_PATHNAME` is used throughout. Key edge case: patterns ending with `**` (e.g. `/**`) do not match paths containing `/` via `File.fnmatch` alone, so the implementation also tries `<glob>/*` as a fallback.

### Value objects

`CodeownersEntry = Data.define(:raw, :pattern, :owners, :comment, :line_number)` is defined in `parser.rb`.

## Testing conventions

- `spec/spec_helper.rb` sets `config.expose_dsl_globally = false` — always use `RSpec.describe` explicitly
- Filesystem-dependent specs (`GhostPatternChecker`, `UncoveredFileChecker`, `MainCli`) use `Dir.mktmpdir` via an `around` block and a `create_file` helper
- `DuplicateCli` specs write to `Tempfile` and call `DuplicateCli#run` directly
- Checker specs are under `spec/lib/checkers/`, CLI specs are under `spec/lib/cli/`
