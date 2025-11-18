# codeowners-validator

GitHub の `CODEOWNERS` ファイルに、**同じパターンが重複して定義されていないか**をチェックするためのシンプルな Ruby 製バリデータです。

例えば、次のように同じパスパターンが複数行に登場していると、どの行が有効なのか分かりづらくなります。

```text
/app/models @team-a
/app/models @team-b # ← 実はこの行だけが有効
```

`codeowners-validator` は、このような「同一パターンの重複」を検出して一覧表示します。

---


## 使い方

### 前提

- Ruby がインストールされていること
- チェック対象の `CODEOWNERS` ファイルが存在すること

### CLI からの利用
指定したパスの `CODEOWNERS` を検証します。
```
bin/check_duplicates CODEOWNERS
```




上記のコマンドは、次のような挙動になります。

- **CODEOWNERS ファイルが存在しない場合**
  - `CODEOWNERS file not found at <パス>` を出力し、終了ステータス `1` を返します。
- **重複エントリが存在する場合**
  - 重複パターンごとに、行番号付きで一覧表示し、終了ステータス `1` を返します。
- **重複エントリが存在しない場合**
  - `No duplicate CODEOWNERS entries found.` を出力し、終了ステータス `0` を返します。

### 出力例

重複エントリがある場合の出力イメージ:

```text
Duplicate CODEOWNERS entries detected:
/app/models
- @team-a at lines 10
- @team-b at lines 25
Total duplicate groups: 1
```

重複がない場合:

```text
No duplicate CODEOWNERS entries found.
```

---

## テスト

このリポジトリでは `rspec` を使用しています。

```bash
bundle install
bundle exec rspec
```
