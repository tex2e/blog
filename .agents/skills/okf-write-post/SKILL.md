---
name: okf-write-post
description: 新しいブログ記事をテーマやメモ・調査内容から自動で執筆し、OKF v0.2 メタデータと Jekyll 互換フロントマターを整えて index.md・log.md の同期とビルド検証まで行う。新しい記事の作成や下書き執筆を依頼されたときに使う。
---

# OKF Blog Post Authoring Skill

本ブログの文体・構造ルールおよび Open Knowledge Format (OKF v0.2) に準拠した新規記事を作成するための標準手順です。

## 前提とルール

- 先に [AGENTS.md](../../AGENTS.md) のフロントマター仕様と執筆指針を確認する。
- 記事内にコマンド実行結果・ベンチマーク・設定手順を書く場合は、実際に検証した内容または一次資料から確認できた事実のみを記し、未確認の数値や挙動を創作しない。
- 生成後、必ず `ruby scripts/okf.rb sync-index`、`ruby scripts/okf.rb log`、`ruby scripts/okf.rb validate`、`bundle exec jekyll build --future` を実行する。

## 手順

### 1. カテゴリ・重複・関連記事の確認

1. [_posts/index.md](../../_posts/index.md) と該当カテゴリの `_posts/<category>/index.md` を確認し、既存の関連記事・重複がないか調べる。
2. 適切なカテゴリディレクトリとファイル名 `_posts/<category>/YYYY-MM-DD-<slug>.md` を決める（`new.sh` のカテゴリ名・カバー画像ルールに合わせる。例: `Crypto` は `/assets/cover4.jpg`、`linux/selinux` は `/assets/cover6.jpg`、その他は `/assets/cover14.jpg`）。
   - `./new.sh <category> <slug>` で雛形を生成してから編集してもよい。

### 2. 調査と記事設計

1. テーマについて公式ドキュメントや一次情報（Web 検索や手元の検証コード等）を確認する。
2. 記事の知識タイプ `type` を決定する（`How-To` / `Concept` / `Reference` / `Troubleshooting` / `Essay` / `Book Chapter`）。
3. 記事構成（冒頭の概要・この記事で分かること → 本題の見出し構成 → まとめ・注意点 → 参考資料）を設計する。

### 3. OKF v0.2 + Jekyll フロントマターの記述

記事先頭に以下の形式で YAML フロントマターを記述する。

```yaml
---
layout:        post
type:          How-To
title:         "タイトル"
description:   "記事内容を1文で簡潔に説明する要約（ASCII二重引用符やHTML記号を含めない）"
tags:          [category-tag, topic-tag-1, topic-tag-2]
status:        stable   # 下書きとして残す場合は draft（かつ draft: true または published: false）
stale_after:   2027-11-14T00:00:00Z   # 変化のある技術記事のみ UTC オフセット付き ISO 8601 で設定
generated:
  by:          <agent>/<model>        # 例: codex/gpt-5, antigravity/gemini, claude-code/claude-sonnet-4-5
  at:          <現在UTC日時 YYYY-MM-DDTHH:MM:SSZ>
sources:
  - id:        ref-1
    resource:  https://...
    title:     "参照ドキュメントのタイトル"
date:          YYYY-MM-DD
category:      CategoryName
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---
```

チェック項目:
- 数式（`$...$`, `$$...$$`）を使うなら `latex: true`
- Mermaid 図（```` ```mermaid ````）を使うなら `mermaid: true`
- クリック拡大画像（`<figure>`）を使うなら `photoswipe: true`
- 関連記事を下に表示したい場合は `similarPosts`（`[../category/slug, "記事タイトル"]`）を設定可能

### 4. 本文執筆

- 冒頭で背景・課題と「この記事で分かること」を簡潔にまとめる。
- 実行コマンド・設定ファイル・前提バージョン・環境情報を明記する。
- 根拠となる外部資料は `sources` に登録した上で本文末尾に `### 参考資料` としてリンクを整理する。
- 相対リンク（他記事へのリンク）は `../<category>/<slug>` または相対パスを正しく記載する。

### 5. 同期・ログ・ビルド検証

1. インデックスを同期する:
   ```bash
   ruby scripts/okf.rb sync-index
   ```
2. `log.md` に記録する:
   ```bash
   ruby scripts/okf.rb log \
     --action Creation \
     --path _posts/<category>/YYYY-MM-DD-<slug>.md \
     --summary "<記事タイトル・概要>" \
     --actor "<agent>/<model>"
   ```
3. 検証とビルドを行う:
   ```bash
   ruby scripts/okf.rb validate
   bundle exec jekyll build --future
   ```
