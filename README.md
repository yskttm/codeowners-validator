# codeowners-validator

A collection of Ruby tools for validating and formatting GitHub `CODEOWNERS` files.

---

## Tools

| Command | Description |
|---|---|
| `bin/check_duplicates` | Detect duplicate pattern definitions |
| `bin/check_ghost_patterns` | Detect patterns pointing to non-existent files or directories |
| `bin/check_uncovered_files` | Detect files not covered by any CODEOWNERS pattern |
| `bin/sort_patterns` | Sort pattern lines by path |

---

## Requirements

- Ruby must be installed
- A `CODEOWNERS` file must exist

---

## Usage

### `check_duplicates` — Detect duplicate definitions

Checks if the same path pattern appears in multiple lines.

```bash
bin/check_duplicates CODEOWNERS
```

```text
Duplicate CODEOWNERS entries detected:
/app/models
- @team-a at lines 10
- @team-b at lines 25
Total duplicate groups: 1
```

---

### `check_ghost_patterns` — Detect patterns pointing to non-existent paths

Reports patterns in CODEOWNERS that do not match any actual file or directory.

```bash
bin/check_ghost_patterns CODEOWNERS
```

```text
Ghost CODEOWNERS patterns detected:
/lib/does_not_exist/foo.rb @owner at line 3
/no/such/dir/ @owner at line 6
Total ghost patterns: 2
```

---

### `check_uncovered_files` — Detect files missing CODEOWNERS coverage

Reports files in the repository that do not match any CODEOWNERS pattern. The `.git/` directory is excluded by default.

```bash
bin/check_uncovered_files CODEOWNERS
```

```text
Uncovered files detected:
- config/settings.yml
- scripts/deploy.sh
Total uncovered files: 2
```

---

### `sort_patterns` — Sort pattern lines

Sorts pattern lines in ascending order by their leading path token and overwrites the file.

- The file header (comment block up to the first blank line) is preserved
- Comment lines are kept with the pattern line that follows them
- The file is not modified if it is already sorted

```bash
bin/sort_patterns CODEOWNERS
```

**before:**
```text
#
# CODEOWNERS
#

/zzz @team-z
/aaa @team-a
```

**after:**
```text
#
# CODEOWNERS
#

/aaa @team-a
/zzz @team-z
```

---

## Common Options

All commands except `sort_patterns` support the `-q / --quiet` flag. It suppresses output and communicates results only via exit status (`0` = ok / `1` = issues found), which is suitable for CI use.

```bash
bin/check_duplicates -q CODEOWNERS
```

---

## Testing

```bash
bundle install
bundle exec rspec
```
