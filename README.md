# codeowners-validator

GitHub の `CODEOWNERS` ファイルを検証・整形するための Ruby 製ツール集です。

---

## 機能一覧

| コマンド | 説明 |
|---|---|
| `bin/check_duplicates` | 同一パターンの重複定義を検出 |
| `bin/check_ghost_patterns` | 実在しないファイル・ディレクトリへの定義を検出 |
| `bin/check_uncovered_files` | CODEOWNERS に定義されていないファイルを検出 |
| `bin/sort_patterns` | パターン行をパス順にソート |

---

## 前提

- Ruby がインストールされていること
- チェック対象の `CODEOWNERS` ファイルが存在すること

---

## 使い方

### `check_duplicates` — 重複定義の検出

同じパスパターンが複数行に登場していないかチェックします。

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

### `check_ghost_patterns` — 存在しないパスへの定義を検出

CODEOWNERS に定義されているパターンが、実際のファイル・ディレクトリにマッチしない場合に報告します。

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

### `check_uncovered_files` — カバーされていないファイルの検出

リポジトリ内のファイルのうち、どの CODEOWNERS パターンにもマッチしないファイルを報告します。`.git/` はデフォルトで除外されます。

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

### `sort_patterns` — パターン行のソート

パターン行を先頭のパス（第 1 トークン）の昇順でソートし、ファイルを上書きします。

- ファイル先頭のヘッダーコメント（最初の空行まで）は保持されます
- コメント行は直後のパターン行に紐付いて一緒にソートされます
- ソート済みの場合はファイルを変更しません

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

## 共通オプション

`sort_patterns` を除く各コマンドは `-q / --quiet` オプションをサポートします。出力を抑制し、終了ステータス（`0` = 正常 / `1` = 問題あり）のみで結果を伝えます。CI での利用に適しています。

```bash
bin/check_duplicates -q CODEOWNERS
```

---

## テスト

```bash
bundle install
bundle exec rspec
```
