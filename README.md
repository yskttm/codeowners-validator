# codeowners-validator

[![CI](https://github.com/yskttm/codeowners-validator/actions/workflows/ci.yml/badge.svg)](https://github.com/yskttm/codeowners-validator/actions/workflows/ci.yml)
[![Ruby](https://img.shields.io/badge/ruby-4.0.2-red?logo=ruby)](https://www.ruby-lang.org/)

A Ruby CLI tool for validating GitHub `CODEOWNERS` files.

---

## Requirements

- Ruby must be installed
- A `CODEOWNERS` file must exist

---

## Usage

```bash
codeowners-validator <subcommand> [options] [CODEOWNERS_PATH]
```

`CODEOWNERS_PATH` を省略した場合、カレントディレクトリの `CODEOWNERS` を使用します。

### Subcommands

| Subcommand | Description |
|---|---|
| `duplicate` | Detect duplicate pattern definitions |
| `ghost` | Detect patterns pointing to non-existent files or directories |
| `uncovered` | Detect files not covered by any CODEOWNERS pattern |

### Options

| Option | Description |
|---|---|
| `-q`, `--quiet` | Suppress output; communicate results via exit status only |

Exit status: `0` = ok / `1` = issues found

---

### `duplicate` — Detect duplicate definitions

Checks if the same path pattern appears in multiple lines.

```bash
codeowners-validator duplicate CODEOWNERS
```

```text
Duplicate CODEOWNERS entries detected:
/app/models
- @team-a at lines 10
- @team-b at lines 25
Total duplicate groups: 1
```

---

### `ghost` — Detect patterns pointing to non-existent paths

Reports patterns in CODEOWNERS that do not match any actual file or directory.

```bash
codeowners-validator ghost CODEOWNERS
```

```text
Ghost CODEOWNERS patterns detected:
/lib/does_not_exist/foo.rb @owner at line 3
/no/such/dir/ @owner at line 6
Total ghost patterns: 2
```

---

### `uncovered` — Detect files missing CODEOWNERS coverage

Reports files in the repository that do not match any CODEOWNERS pattern. The `.git/` directory is excluded by default.

```bash
codeowners-validator uncovered CODEOWNERS
```

```text
Uncovered files detected:
- config/settings.yml
- scripts/deploy.sh
Total uncovered files: 2
```

---

## Testing

```bash
bundle install
bundle exec rspec
```
