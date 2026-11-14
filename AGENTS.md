# AGENTS.md — 晴耕雨読 ブログ運用・記事作成ガイド

このリポジトリは Jekyll で構築された技術ブログ「晴耕雨読」（`https://tex2e.github.io/blog/`）であり、**Open Knowledge Format (OKF v0.2)** に準拠して記事メタ情報・階層インデックス（`index.md`）・変更履歴（`log.md`）を管理しています。

## 1. コンテキスト探索（Progressive Disclosure）

全記事（660本以上）を一度に探索・読み込みしないでください。以下の順で必要なファイルだけを参照します。

1. [index.md](./index.md) — バンドル全体の概要とカテゴリ一覧
2. [_posts/index.md](./_posts/index.md) — カテゴリ別の記事数・サブディレクトリ一覧
3. `_posts/<category>/index.md` — 該当カテゴリ内の記事一覧（タイトル、`type`、`status`、`stale_after`、要約）
4. 対象記事 `_posts/<category>/YYYY-MM-DD-slug.md`
5. [log.md](./log.md) — 直近の変更履歴

## 2. OKF v0.2 + Jekyll フロントマター仕様

すべての記事（`_posts/**/*.md`、予約ファイル `index.md` / `log.md` を除く）は以下の規約に従います。

### OKF フィールド

- `type` *(必須)*: 次のいずれかを使用します。
  - `How-To`: 導入手順、設定方法、チュートリアル、実装ガイド
  - `Concept`: 理論解説、数学・暗号原理、アルゴリズム、プロトコル・仕組みの解説
  - `Reference`: コマンド一覧、対応表、構文・仕様まとめ、チートシート
  - `Troubleshooting`: エラー原因の調査、対処法、トラブル解決記録
  - `Essay`: 考察、振り返り、イベント参加記、キャリア・思考に関する雑記
  - `Book Chapter`: `layout: book` を使った章立て解説シリーズ
  - `Template`: テーマ付属のサンプル記事
- `title`: 記事タイトル（二重引用符で囲む。Jekyll の `<title>` や一覧表示に使用）
- `description`: 記事内容を1文で簡潔に表す要約（45〜140文字程度）。`head.html` / `ogp.html` の `meta` 属性へそのまま出力されるため、**ASCII 二重引用符 `"`、`<`、`>`、`{{`、`{%`、改行を含めないこと**（引用は「」を使用）
- `tags`: **YAML リスト形式**（例: `tags: [python, tts, gpu]`）。スペース区切り文字列は禁止。小文字英数字とハイフン（2〜5個）
- `status`: `draft` / `stable` / `deprecated` のいずれか
  - `draft: true` または `published: false` の記事は `status: draft`
  - 公開記事は `status: stable`（旧記事が完全に非推奨・廃止された場合は `deprecated`）
- `stale_after`: 技術的鮮度の再確認期限（**UTC オフセット付き ISO 8601 日時**。例: `2027-11-14T00:00:00Z`。`YYYY-MM-DD` のみの日付表記は OKF v0.2 違反のため禁止）
  - 変化の速い技術（AI/LLM、クラウド AWS/Azure/GCP、Web/ブラウザ、Python/Ruby/JS パッケージ、CVE/ツール手順）: **作成/検証から1年後**
  - 安定した技術（Linux/SELinux、DB/SQL、PowerShell/Windows/Dotnet、Git/LaTeX/Makefile、ネットワークプロトコル）: **作成/検証から3年後**
  - 普遍的内容（純粋数学、暗号理論の数学証明、エッセイ、振り返り、`draft`）: 省略可
- `generated`: 生成・作成の来歴
  ```yaml
  generated:
    by: human:tex2e   # または codex/gpt-5, claude-code/claude-sonnet-4-5, antigravity/gemini 等
    at: 2026-11-14T12:00:00Z
  ```
- `verified` *(任意・検証時のみ記録)*: ソースや実機環境と照合して内容を検証した履歴のリスト。未検証の過去記事には捏造して付けないこと。
  ```yaml
  verified:
    - by: human:tex2e
      at: 2026-11-14T12:00:00Z
  ```
- `sources` *(任意・外部参照がある場合)*: 根拠となる公式ドキュメントや参考資料
  ```yaml
  sources:
    - id: official-docs
      resource: https://example.org/docs
      title: "Official Documentation"
      last_modified: 2026-11-01T00:00:00Z
  ```

### Jekyll 互換フィールド（既存設定を維持）

- `layout`: `post`（通常記事）または `book`（シリーズ章）
- `date`: `YYYY-MM-DD`
- `category`: カテゴリ名（`new.sh` のマッピングに従う。例: `Crypto`, `Python`, `Misc`, `Infrastructure`, `SELinux`, `Dotnet`, `PowerShell`, `JavaScript`, `LaTeX`, `VB.NET`, `PHP`, `WindowsBatch`, `RFC`）
- `cover`: `/assets/cover14.jpg`（`Crypto` は `/assets/cover4.jpg`、`linux/selinux` は `/assets/cover6.jpg`）
- `redirect_from`, `comments`, `published`, `latex`, `photoswipe`, `mermaid`, `similarPosts`, `sections`, `section_number`

## 3. 記事執筆・更新スタイル指針

このブログの基本方針（`_posts/misc/2025-11-03-blog-writing-and-ai.md`, `_posts/misc/2026-03-08-ai-accelerates-thinking.md`, `_posts/python/2026-09-27-irodori-tts.md` 等に準拠）:

- **検証された事実と前提環境の明記**: コマンド・バージョン・OS・日時・参照ドキュメントを確認した上で記述し、未確認の推測や架空の実行結果を事実として書かない。
- **結論と読める価値の明確化**: 冒頭で「この記事で何ができるようになるか・分かるか」を示し、具体的な手順・コード例・注意点（前提条件や限界）を添える。
- **日本語技術記事として自然な構成**: 見出し階層（`##`, `###`）を整理し、必要に応じた参考資料セクションを設ける。
- **図表・数式フラグ**: `$...$` / `$$...$$` を使う場合は `latex: true`、`language-mermaid` を使う場合は `mermaid: true`、拡大画像を使う場合は `photoswipe: true` を有効にする。

## 4. 変更後の必須チェック・コマンド

記事の作成・更新・メタデータ修正を行ったら、必ず以下を実行してください。

```bash
# 1. カテゴリ index.md とルート index.md を同期
ruby scripts/okf.rb sync-index

# 2. log.md に変更履歴を記録
ruby scripts/okf.rb log --action Update --path _posts/.../YYYY-MM-DD-slug.md --summary "変更内容の要約" --actor "agent/model"

# 3. OKF v0.2 + Jekyll メタデータ整合性を検証
ruby scripts/okf.rb validate

# 4. Jekyll ビルド確認
bundle exec jekyll build --future
```

鮮度切れ記事を調べる場合:

```bash
ruby scripts/okf.rb stale --limit 20
```

## 5. 利用可能なエージェントスキル

`.agents/skills/`（Claude Code 向けには `.claude/skills/` からシンボリックリンク）に以下の共通スキルが定義されています。

- `okf-maintain-blog`: `stale_after` 期限切れや陳腐化した記事を自動検出し、最新仕様を調査・反映して `verified`・`stale_after`・`index.md`・`log.md` を更新する。
- `okf-write-post`: 指定されたテーマ・資料・調査結果をもとに、本ブログの文体と OKF v0.2 + Jekyll 仕様に完全準拠した新規記事を自動執筆する。
- `okf-sync-validate`: 手動編集後に `index.md` 同期・`log.md` 追記・OKF 検証・Jekyll ビルド確認を一括実施する。
