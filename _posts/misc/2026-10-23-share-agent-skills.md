---
layout:        post
title:         "Claude Code・Codex・Antigravityでリポジトリのスキルを共有する"
date:          2026-10-23
category:      Misc
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Claude Code、Codex、Antigravity（agy）で、同じリポジトリの `.agents/skills/` に置いたスキルを共有する方法を説明します。
フォルダ構成とスキルの配置、各ツールからの読み込み設定、呼び出し方を示します。

私は普段、Claude Code、Codex、Antigravityの3種類を使っています。
Claude Codeにはコーディング、Codexにはレビュー、Antigravityには文章作成を任せる、という感じで使い分けています。

担当する作業は違っても、リポジトリ固有のルールや作業手順は共通で使いたいところです。
ツールごとに同じ内容をコピーすると更新時に手間がかかるので、スキルの実体を1か所にまとめて管理する構成にします。

フォルダ名は **`.agents/skills`（skillsは複数形）** です。
2026年10月23日時点の公式ドキュメントでは、CodexとAntigravityはこのフォルダを読み込めます。
Claude Codeには `.claude/skills/` からスキル単位でシンボリックリンクを作成します。
以下では、ローカルのリポジトリを扱うClaude Code、Codex CLI、Antigravity CLIを対象に説明します。

### 3ツールのスキル配置先

スキルは、特定の作業で使う手順や参考資料をまとめたフォルダです。
共通の形式である [Agent Skills](https://agentskills.io/specification) では、フォルダ内に `SKILL.md` を置き、冒頭のYAMLに名前と用途、その後のMarkdownに手順を記述します。

ただし、形式が共通でも、スキルを探す場所はツールによって異なります。
今回使用するリポジトリ内の配置先は次のとおりです。

| ツール | リポジトリ内の配置先 | 今回の対応 |
| --- | --- | --- |
| [Claude Code](https://code.claude.com/docs/en/skills#choose-where-skills-load) | `.claude/skills/<name>/SKILL.md` | 共通フォルダへのリンクを配置 |
| [Codex](https://learn.chatgpt.com/docs/build-skills#where-codex-loads-local-skills) | `.agents/skills/<name>/SKILL.md` | 実体を直接読み込む |
| [Antigravity](https://antigravity.google/docs/skills) | `.agents/skills/<name>/SKILL.md` | 実体を直接読み込む |

Antigravityの旧来の配置先には `.agent/skills/`（agentが単数形）もあり、現行ドキュメントでは後方互換の対象とされています。
新しく共通化する場合は、現在の標準配置先である `.agents/skills/` を使います。
古いバージョンを使っている場合は、更新してから検出を確認してください。

完成時の構成は次のようになります。

```text
repository/
├── .agents/
│   └── skills/
│       └── review-changes/
│           └── SKILL.md
└── .claude/
    └── skills/
        └── review-changes -> ../../.agents/skills/review-changes
```

編集するのは `.agents/skills/review-changes/SKILL.md` の1ファイルだけです。
Claude Codeもリンク先の同じファイルを参照するため、ツールごとに内容を同期する必要がなくなります。

### 共通スキルを配置する

例として、`review-changes` という名前のスキルを配置します。
以下のコマンドはmacOS / Linuxのシェルを想定しています。
リポジトリのルートで実行します。

```bash
mkdir -p .agents/skills/review-changes
```

作成したフォルダに、共有するスキルの `SKILL.md` を保存します。
既存のスキルを移す場合は、関連する参考資料や補助スクリプトも同じフォルダ内にまとめて移します。

### Claude Codeから共通スキルを参照する

Claude Codeは、`.claude/skills/` 内のスキルフォルダがシンボリックリンクになっている構成を公式にサポートしています。
共通スキルへのリンクを、スキルごとに作成します。
根拠は公式ドキュメントの [Symlinked folders](https://code.claude.com/docs/en/skills#choose-where-skills-load) の説明です。

以下は `.claude/skills/review-changes` という同名のファイル・フォルダ・リンクが存在しない状態を前提とします。
既存のスキルがある場合は、内容を比較し、共通フォルダに統合してから配置を変更してください。

```bash
mkdir -p .claude/skills
ln -s ../../.agents/skills/review-changes .claude/skills/review-changes
```

リンク先の `../../` は、コマンドを実行した場所ではなく、リンクを置く `.claude/skills/` からの相対位置です。
2階層上のリポジトリルートに戻り、そこから `.agents/skills/review-changes` を参照します。
絶対パスを埋め込まないため、別の場所にcloneしても同じ構成を使えます。

リンク先とファイルの内容を確認します。

```bash
readlink .claude/skills/review-changes
# ../../.agents/skills/review-changes

cmp .agents/skills/review-changes/SKILL.md .claude/skills/review-changes/SKILL.md
# 内容が一致していれば何も表示されず、終了コードは0
```

チームで共有するときは、スキルの実体とシンボリックリンクの両方をGitの管理対象にします。

```bash
git add .agents/skills/review-changes .claude/skills/review-changes
```

Windowsを含むチームでは、clone先でもシンボリックリンクが復元されるか確認が必要です。
リンクの作成・復元ができない環境でコピーを使う場合は、`.agents/skills/` を編集元とし、更新時にコピーし直す手順を用意します。

### 各ツールでスキルを呼び出す

配置後は、各ツールをリポジトリのルートで開始し、明示的にスキルを指定して確認します。
呼び出し方はツールごとに異なります。

| ツール | チャットへの入力例 |
| --- | --- |
| Claude Code | `/review-changes` |
| Codex CLI | `$review-changes 現在の変更をレビューして` |
| Antigravity CLI | `/review-changes` |

Claude CodeとAntigravityのスラッシュコマンド、Codex CLIの `$` による指定は、それぞれの [Claude Code公式ドキュメント](https://code.claude.com/docs/en/skills)、[Antigravity公式ドキュメント](https://antigravity.google/docs/skills)、[OpenAI公式ドキュメント](https://learn.chatgpt.com/docs/build-skills#how-chatgpt-and-codex-use-skills) に記載されています。

名前が候補に表示されるかに加え、読み込んだ `SKILL.md` のパスと、レビューの出力形式も確認します。
見つからない場合は、ファイル名が `SKILL.md` になっているか、YAMLの形式が正しいか、Claude Codeのリンク先が存在するかを確認し、セッションを開始し直します。
別の場所に同名のスキルを導入している場合は、意図したスキルを読み込んでいるかも確認してください。

3ツールとも依頼の内容に応じてスキルを選択できますが、自動選択されるかは説明文と依頼内容に左右されます。
導入時の確認では、上記のように名前を指定する方が、検出の問題と自動選択の問題を切り分けられます。

### 共通化する範囲

**同じファイルを共有できることと、同じ動作を保証できることは別です。**
この構成で共有するのは、作業手順やレビュー基準です。
利用できるコマンド、MCPサーバー、実行権限は、各ツールの環境に依存します。

共通スキルでは、まず `name` と `description`、通常のMarkdownによる手順に絞ると管理しやすくなります。
たとえばClaude Codeの `context: fork` や `hooks` は独自機能なので、他のツールでも同じように働く前提で共通手順に組み込むことは避けます。
Claude Code固有の拡張については [公式のfrontmatter一覧](https://code.claude.com/docs/en/skills#frontmatter-reference) で確認できます。

スクリプトを追加する場合も、Node.jsやPythonなどの必要な実行環境と、コマンドを実行するディレクトリを明記します。
実行権限をYAMLに書けば全ツールで有効になる、といった前提を置かず、各環境で動作を確認します。

### 参考資料

- [Agent Skills Specification](https://agentskills.io/specification)
- [Claude Code: Extend Claude with skills](https://code.claude.com/docs/en/skills)
- [OpenAI: Build skills](https://learn.chatgpt.com/docs/build-skills)
- [Google Antigravity: Agent skills](https://antigravity.google/docs/skills)
