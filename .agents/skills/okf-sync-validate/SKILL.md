---
name: okf-sync-validate
description: ブログ記事を手動で追加・編集した後に、OKF v0.2 メタデータ整合性の検証、カテゴリ別およびルート index.md の再同期、log.md への履歴記録、Jekyll ビルド確認を一括で実行する。
---

# OKF Sync & Validate Skill

記事ファイルの手動作成・編集後に、OKF バンドル構造と Jekyll ビルドの整合性を保つためのスキルです。

## 手順

1. 変更された記事（`git status` / `git diff`）を確認し、OKF 必須項目（`type`, `title`, `description`, `tags`, `status`, `generated`）に不足や形式誤りがないか確認する。
2. カテゴリおよびルートの `index.md` を同期する:
   ```bash
   ruby scripts/okf.rb sync-index
   ```
3. まだ `log.md` に記録されていない新規作成・更新があれば記録する:
   ```bash
   ruby scripts/okf.rb log --action Update --path _posts/.../file.md --summary "要約" --actor "human:tex2e"
   ```
4. OKF 検証および Jekyll ビルドを実行する:
   ```bash
   ruby scripts/okf.rb validate
   bundle exec jekyll build --future
   ```
5. エラー・警告が出た場合は原因箇所を修正し、再度 `validate` と `jekyll build` がパスすることを確認する。
