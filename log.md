# Blog Knowledge Update Log

このファイルは [Open Knowledge Format (OKF v0.2)](./index.md) に基づくブログ記事およびメタ情報の変更履歴（逆時系列）です。
記事の新規作成・更新・鮮度検証・非推奨化を行った際は、`ruby scripts/okf.rb log` または手動追記で記録してください。

## 2026-11-14
- **Update**: [_posts/misc/2026-11-14-open-knowledge-format.md](./_posts/misc/2026-11-14-open-knowledge-format.md) — LayerXのLLM Wiki組織運用に関する知見と出典を追記 (`antigravity/gemini`)
- **Creation**: [_posts/misc/2026-11-14-open-knowledge-format.md](./_posts/misc/2026-11-14-open-knowledge-format.md) — OKF v0.2 の仕組みと本ブログへの適用経緯・設計の解説記事を追加 (`antigravity/gemini`)
- **Initialization**: 全664記事へ OKF v0.2 メタデータ（`type`, `description`, `tags`, `status`, `stale_after`, `generated`, `sources`）を整備し、階層型 `index.md`・`log.md`・`AGENTS.md`・共有スキル（`.agents/skills/`）・検証スクリプト（`scripts/okf.rb`）・GitHub Actions 定期鮮度チェックを構築。
