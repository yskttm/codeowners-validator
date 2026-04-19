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

CLI tools (require a CODEOWNERS file as argument):

```bash
ruby bin/check_duplicates CODEOWNERS
ruby bin/check_ghost_patterns CODEOWNERS
ruby bin/check_uncovered_files CODEOWNERS
ruby bin/sort_patterns CODEOWNERS
```

## Architecture

Each tool follows the same pipeline pattern:

```
bin/<command> → Parser → <Checker or Transformer> → output / exit status
```

- **`lib/codeowners_validator.rb`** — top-level require that loads all components
- **`lib/codeowners_validator/parser.rb`** — parses CODEOWNERS lines into `CodeownersEntry` value objects (`Data.define`); skips blank lines and comment lines
- **`lib/codeowners_validator/duplicate_checker.rb`** — groups entries by pattern, returns those with size > 1
- **`lib/codeowners_validator/ghost_pattern_checker.rb`** — checks each pattern against the filesystem (`Dir.glob` / `Dir.exist?`); takes `repo_root` as the base path
- **`lib/codeowners_validator/uncovered_file_checker.rb`** — enumerates all files under `repo_root` and checks each against CODEOWNERS patterns via `File.fnmatch`; excludes `.git/` by default
- **`lib/codeowners_validator/sort_patterns.rb`** — sorts pattern lines by leading path token; preserves the file header (lines up to the first blank line); keeps comment lines attached to the pattern line that follows them

### Pattern matching notes (`uncovered_file_checker.rb`)

`File::FNM_PATHNAME` is used throughout. Key edge case: patterns ending with `**` (e.g. `/**`) do not match paths containing `/` via `File.fnmatch` alone, so the implementation also tries `<glob>/*` as a fallback.

### Value objects

`CodeownersEntry = Data.define(:raw, :pattern, :owners, :comment, :line_number)` is defined in `parser.rb`. The copy in `entry.rb` and the unused `DuplicateLineChecker` are dead code.

## Testing conventions

- `spec/spec_helper.rb` sets `config.expose_dsl_globally = false` — always use `RSpec.describe` explicitly
- Filesystem-dependent specs (`GhostPatternChecker`, `UncoveredFileChecker`) use `Dir.mktmpdir` via an `around` block and a `create_file` helper
- `Cli` specs write to `Tempfile` and call `Cli#run` directly
