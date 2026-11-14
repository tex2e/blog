---
okf_version: "0.2"
---
# 晴耕雨読 Knowledge Bundle (OKF v0.2)

このリポジトリは、Mako (`@tex2e`) の技術ブログ「晴耕雨読」（Jekyll サイト `https://tex2e.github.io/blog/`）を、Google Cloud の **Open Knowledge Format (OKF v0.2)** に準拠した知識ベースとして構造化したバンドルです。

> **Note (Jekyll との共存)**: `index.md`, `log.md`, `AGENTS.md`, `CLAUDE.md`, `scripts/`, `.agents/`, `.claude/` は `_config.yml` の `exclude` に登録されており、公開 Web サイト（`index.html` 等）のビルド出力には影響しません。

## エントリーポイント（Progressive Disclosure）

AI エージェントは全記事を一度に読み込まず、以下の階層を辿って必要なコンテキストだけを段階的に取得してください。

1. **規約・運用ルール**: [AGENTS.md](./AGENTS.md)
2. **変更履歴**: [log.md](./log.md)
3. **カテゴリ一覧**: [_posts/index.md](./_posts/index.md)
4. **各カテゴリの目次**: `_posts/<category>/index.md` → 個別記事 `_posts/<category>/YYYY-MM-DD-slug.md`

## OKF メタデータ規約（概要）

各記事の YAML フロントマターは Jekyll 互換フィールドに加えて以下の OKF v0.2 フィールドを持ちます。

- `type` *(必須)*: `How-To` / `Concept` / `Reference` / `Troubleshooting` / `Essay` / `Book Chapter` / `Template`
- `title`, `description`, `tags` *(YAML リスト)*
- `status`: `draft` / `stable` / `deprecated`
- `stale_after`: 技術的陳腐化が見込まれる記事の再確認期限（UTC オフセット付き ISO 8601: `YYYY-MM-DDTHH:MM:SSZ`）。数学証明やエッセイなど普遍的内容は省略可
- `generated`: `{ by: human:tex2e | <agent>/<model>, at: <ISO 8601 UTC> }`
- `verified`: `[{ by: ..., at: <ISO 8601 UTC> }]`（外部資料・実機確認による検証履歴）
- `sources`: 参照元リソース一覧（`id`, `resource`, `title`, `last_modified`）

## カテゴリ別インデックス

<!-- OKF:INDEX:START -->
Total articles: **665** across **29** top-level categories ([full category map](./_posts/index.md)).

| Category | Articles | Index |
|---|---:|---|
| blog | 5 | [_posts/blog/index.md](./_posts/blog/index.md) |
| c | 4 | [_posts/c/index.md](./_posts/c/index.md) |
| crypto | 65 | [_posts/crypto/index.md](./_posts/crypto/index.md) |
| database | 15 | [_posts/database/index.md](./_posts/database/index.md) |
| dotnet | 56 | [_posts/dotnet/index.md](./_posts/dotnet/index.md) |
| english | 6 | [_posts/english/index.md](./_posts/english/index.md) |
| git | 11 | [_posts/git/index.md](./_posts/git/index.md) |
| infra | 46 | [_posts/infra/index.md](./_posts/infra/index.md) |
| java | 8 | [_posts/java/index.md](./_posts/java/index.md) |
| javascript | 19 | [_posts/javascript/index.md](./_posts/javascript/index.md) |
| keyboard | 13 | [_posts/keyboard/index.md](./_posts/keyboard/index.md) |
| latex | 11 | [_posts/latex/index.md](./_posts/latex/index.md) |
| linux | 58 | [_posts/linux/index.md](./_posts/linux/index.md) |
| makefile | 5 | [_posts/makefile/index.md](./_posts/makefile/index.md) |
| math | 13 | [_posts/math/index.md](./_posts/math/index.md) |
| misc | 33 | [_posts/misc/index.md](./_posts/misc/index.md) |
| powershell | 46 | [_posts/powershell/index.md](./_posts/powershell/index.md) |
| programming | 21 | [_posts/programming/index.md](./_posts/programming/index.md) |
| protocol | 35 | [_posts/protocol/index.md](./_posts/protocol/index.md) |
| psychology | 12 | [_posts/psychology/index.md](./_posts/psychology/index.md) |
| python | 30 | [_posts/python/index.md](./_posts/python/index.md) |
| regex | 5 | [_posts/regex/index.md](./_posts/regex/index.md) |
| ruby | 10 | [_posts/ruby/index.md](./_posts/ruby/index.md) |
| security | 18 | [_posts/security/index.md](./_posts/security/index.md) |
| selinux | 44 | [_posts/selinux/index.md](./_posts/selinux/index.md) |
| shell | 31 | [_posts/shell/index.md](./_posts/shell/index.md) |
| vb.net | 13 | [_posts/vb.net/index.md](./_posts/vb.net/index.md) |
| windows | 18 | [_posts/windows/index.md](./_posts/windows/index.md) |
| windowsbatch | 14 | [_posts/windowsbatch/index.md](./_posts/windowsbatch/index.md) |
<!-- OKF:INDEX:END -->

## バリデーション・運用コマンド

```bash
ruby scripts/okf.rb validate              # OKF v0.2 + index.md 整合性検証
ruby scripts/okf.rb stale                 # stale_after 期限切れ記事の抽出
ruby scripts/okf.rb sync-index            # index.md 一括再生成
```
