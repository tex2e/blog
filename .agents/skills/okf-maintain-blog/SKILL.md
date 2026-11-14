---
name: okf-maintain-blog
description: ブログ記事の鮮度（stale_after）やリンク切れ・技術変更を点検し、最新情報に基づいて記事本文と OKF v0.2 メタデータ（verified, stale_after, sources, status, index.md, log.md）を自動更新する。ブログの定期メンテナンスや最新化を依頼されたときに使う。
---

# OKF Blog Maintenance Skill

Open Knowledge Format (OKF v0.2) の鮮度・信頼性シグナル（`stale_after`, `verified`, `sources`, `status`）を用いて、このブログの記事を最新の状態に保つための標準手順です。

## 前提とルール

- 先に [AGENTS.md](../../AGENTS.md) と [index.md](../../index.md) の規約を確認する。
- 事実確認を行わずに `verified` を付けたり、内容を推測で書き換えたりしない。Web 検索や公式ドキュメント等で必ず一次情報を確認する。
- 更新後の確認として `ruby scripts/okf.rb validate` と `bundle exec jekyll build --future` を必ず成功させる。

## 手順

### 1. 要確認記事の特定

1. 鮮度レポートを実行し、`stale_after` を過ぎている記事または期限間近の記事をリストアップする。
   ```bash
   ruby scripts/okf.rb stale --limit 20 --json
   ```
2. ユーザーから特定カテゴリ・記事の指定がない場合は、直近で重要度・更新効果の高い記事（または未検証かつ期限切れの記事）から優先的に対象を選ぶ。必要に応じて関連カテゴリの `_posts/<category>/index.md` を読む。

### 2. 記事の精査と一次情報の調査

対象記事を読み込み、以下を確認する。

- 記載されているソフトウェア・ライブラリ・クラウドサービス・OS・コマンド・仕様に破壊的変更、EOL、非推奨化、新標準への移行がないか。
- `sources` および本文中の外部リンクが生きているか、内容が現在の公式情報と一致しているか。
- 記事内のコード例や手順に時代遅れ（例: 非推奨オプションや廃止された API）がないか。

### 3. 記事本文とメタ情報の更新

調査結果に応じて記事を適切に更新する。

- **内容が現在も有効な場合**: 本文は無理に変えず、必要なら検証日・確認バージョンを補足する。
- **内容の一部が古くなっている場合**: 最新の手順・バージョン・代替手段へ書き直す（歴史的経緯を残す価値がある場合は更新履歴や注記を添える）。著者の経験・考察・体験談の部分は原文の意図と文体を尊重して保持する。
- **対象技術自体が完全に終了・廃止された場合**: 冒頭に終了・後継技術への案内を追記し、`status: deprecated` に変更する。

フロントマターの更新:

1. `verified`: 今回の確認記録をリスト末尾へ追記する（既存履歴は消さない）。
   ```yaml
   verified:
     - by: <your-agent-name>/<model-id>   # 例: codex/gpt-5, antigravity/gemini, claude-code/claude-sonnet-4-5
       at: <現在UTC日時 YYYY-MM-DDTHH:MM:SSZ>
   ```
2. `stale_after`: 記事の技術変動性に合わせて次回確認期限を設定・更新する（変化の速い技術は +1年、安定技術は +3年。`status: deprecated` にした場合は省略可）。必ず `YYYY-MM-DDTHH:MM:SSZ` 形式にする。
3. `sources`: 参照・確認した公式ドキュメント URL や `last_modified` を最新化する。
4. `description` / `tags`: 本文の変更に合わせて必要なら見直す（`description` に ASCII `"`・`<`・`>`・`{{`・`{%`・改行を含めないこと）。

### 4. インデックス同期・ログ記録・検証

1. 各 `index.md` を同期する。
   ```bash
   ruby scripts/okf.rb sync-index
   ```
2. `log.md` に変更履歴を追記する（内容更新なら `Update`、内容確認のみで再検証した場合は `Verification`、非推奨化なら `Deprecation`）。
   ```bash
   ruby scripts/okf.rb log \
     --action Update \
     --path _posts/<category>/<filename>.md \
     --summary "<具体的な更新・確認内容>" \
     --actor "<agent>/<model>"
   ```
3. OKF バリデーションと Jekyll ビルドを実行する。
   ```bash
   ruby scripts/okf.rb validate
   bundle exec jekyll build --future
   ```
4. 変更した記事、確認した一次情報・URL、更新点、検証結果を簡潔に報告する。
