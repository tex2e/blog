---
layout:        post
title:         "Open Knowledge Format (OKF) の解説とブログへの導入"
type:          Concept
description:   "Google CloudのOpen Knowledge Format (OKF v0.2)の仕組みと、600本以上の記事を持つ個人ブログをAIで自律保守できる知識ベースへ整備した経緯・設計を解説します。"
tags:          [misc, okf, ai, markdown, blog]
status:        stable
stale_after:   2027-11-14T00:00:00Z
generated:
  by:          antigravity/gemini
  at:          2026-11-14T04:44:10Z
sources:
  - id:        ref-1
    resource:  https://github.com/GoogleCloudPlatform/open-knowledge-format
    title:     "GoogleCloudPlatform/open-knowledge-format (GitHub)"
  - id:        ref-2
    resource:  https://github.com/GoogleCloudPlatform/open-knowledge-format/blob/main/SPEC.md
    title:     "Open Knowledge Format Specification (SPEC.md)"
  - id:        ref-3
    resource:  https://www.youtube.com/watch?v=Vl6LoetSqEI
    title:     "Googleが標準化しようとしているMarkdownの書き方「OKF」って何？（クロイッチチャンネル）"
  - id:        ref-4
    resource:  https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f
    title:     "LLM Wiki (Andrej Karpathy)"
date:          2026-11-14
category:      Misc
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
similarPosts:
  - [../misc/share-agent-skills, "Claude Code・Codex・Antigravityでリポジトリのスキルを共有する"]
  - [../misc/ai-accelerates-thinking, "AIと生きる：思考を止めるな、加速させよ"]
  - [../misc/blog-writing-and-ai, "AIが情報を要約する現代において私たちが記事を書く意味とは"]
# sitemap: false
# feed:    false
---

2016年に書き始めたこのブログも、気づけば**600本以上**の記事が溜まりました。
記事数が増えるにつれて、「数年前に書いた手順がOSやツールのアップデートで動かなくなっていないか」「AIにメンテナンスや新規執筆を手伝ってもらおうにも、記事が多すぎて全体像をうまく渡せない」という悩みも大きくなっていきました。

こうした課題を解決する手がかりとして出会ったのが、Google Cloudが公開した **Open Knowledge Format（OKF）** です。
OKFは「YAMLフロントマター付きのMarkdownファイルとディレクトリ構造」というシンプルな仕組みだけで、人間にもAIエージェントにも扱いやすい知識ベース（Knowledge Bundle）を作るためのオープン仕様です。

この記事では、OKFの仕組みと考え方を整理したうえで、600本以上の記事を抱えるこのJekyllブログへOKF v0.2を導入し、**AIが自律的に鮮度を点検・更新し、新しい記事まで執筆できる環境**を整えた経緯と設計を紹介します。

この記事で分かることは次のとおりです。

- Open Knowledge Format（OKF）が生まれた背景と、v0.2の仕組み
- `AGENTS.md`や`llms.txt`との違いと組み合わせ方
- 既存JekyllブログへOKF v0.2を導入する際の設計と注意点
- 手元のMarkdownやブログに小さくOKFを取り入れる第一歩

## Open Knowledge Format (OKF) とは何か

Open Knowledge Format（OKF）は、Google CloudがGitHub上で公開・標準化を進めている、人間とAIエージェントが知識や文脈を共有するための軽量フォーマット仕様です。
社内ドキュメント、データ基盤のテーブル定義、KPIの計算ロジック、運用手順書（Runbook）など、ツールや部門ごとに散らばりがちな文脈を1つの共通形式で表現することを目的に設計されています。

### 背景：「RAGで毎回探す」から「LLM Wikiとして育てる」へ

OKFの根底にあるのは、2026年4月にAndrej Karpathy氏が提唱した **LLM Wiki パターン** です。

従来のRAG（検索拡張生成）では、質問が来るたびにPDFやドキュメントの断片をベクトル検索し、その場で答えを組み立てます。
導入しやすい一方で、「質問のたびにゼロから情報を探して組み立て直す」状態になりやすく、文書間の矛盾を解消したり、複数の資料から得た知見を育てていったりするのが難しくなります。

そこで注目されたのが、生資料をもとにLLMが相互リンクされたMarkdownのWikiを作り、継続的に更新・維持していく **LLM Wiki** という考え方です。
Google Cloudは、人やツールごとにバラバラに実装されていたこのパターンを特定の環境へ依存しないオープン標準として整理し、2026年6月にOKF v0.1を公開しました。
続く2026年7月の **OKF v0.2** では、AIエージェントが大量の知識を自律的に生成・更新する運用を前提に、「その情報をどこまで信頼してよいか」「まだ新しいか」を判断するための信頼性・鮮度シグナルが追加されています。

### 基本思想：「プラットフォームではなくフォーマット」

OKFの設計思想を一言で表すなら **「プラットフォームではなくフォーマット（Just files and markdown）」** です。

- 専用のデータベース、ベクトルストア、独自SDK、常駐ランタイムは不要です
- 実体は **YAMLフロントマター付きのMarkdownファイル（`.md`）を階層ディレクトリに並べた構造**（Knowledge Bundleと呼びます）です
- テキストエディタやObsidianでもそのまま開け、`git clone`で丸ごと持ち運べ、GitのPull Requestと`git diff`でレビューできます
- 必須のフロントマターは原則 **`type`の1項目だけ** とゆるやかで、読み取る側のツールが未定義のフィールドをそのまま無視できる柔軟な仕様になっています

新しく大掛かりなナレッジ管理基盤を導入しなくても、いま手元にあるMarkdownフォルダに少しずつ約束事を足すだけで始められます。

### 段階的開示（Progressive Disclosure）と予約ファイル

記事やドキュメントが数百本を超えてくると、AIエージェントに「ディレクトリ内の全ファイルを一度に読め」と指示するわけにはいきません。
コンテキストウィンドウを圧迫し、精度が落ちたりコストがかさんだりするためです。

そこでOKFでは、予約ファイルである **`index.md`** と **`log.md`** を使って **Progressive Disclosure（段階的開示）** を行います。

```text
knowledge-bundle/
├── index.md          # okf_version: "0.2" と全体・主要カテゴリの目次
├── log.md            # 時系列の変更履歴（追記ログ）
└── category-a/
    ├── index.md      # カテゴリ内の記事一覧・種別・状態・要約
    └── article.md    # type などのメタデータと本文
```

AIエージェントはまずルートの`index.md`だけを読み、目当てのカテゴリを特定してから下位の`index.md`を辿り、本当に必要な数本の`.md`ファイルだけを開きます。
直近で何が更新されたかを知りたいときも、`log.md`を見れば全体を読み直さずに把握できます。

### OKF v0.2の信頼性・鮮度シグナル

個人のブログでも組織のWikiでも、AIが記事を自動生成・自動修正する時代になると「この記述をそのまま信じてよいのか」「数年前の古い手順のまま放置されていないか」という問題が避けられません。
OKF v0.2では、こうした状態をメタデータで管理するために次のようなフィールドや仕組みを定義しています。

| フィールド / 仕組み | 役割 | 運用のポイント |
| --- | --- | --- |
| `type` *(必須)* | 知識の種別を表す | 用途に応じて種類を宣言する（例: `How-To`, `Concept`, `Reference`, `Troubleshooting`, `Essay`） |
| `status` | ライフサイクル状態 | `draft` / `stable` / `deprecated`で公開中か廃止済みかを区別する |
| `stale_after` | 鮮度の有効期限 | 「1年後」のような相対表現ではなく、**UTCオフセット付きの絶対日時**（例: `2027-11-14T00:00:00Z`）で書き、現在時刻との比較だけで期限切れを機械判定する |
| `generated` | 生成の来歴 | `by`（誰が・どのモデルが）と`at`（いつ）を記録し、AI生成か人間執筆かを明示する |
| `verified` | 検証の履歴 | 「書いた人（`generated`）」と「一次情報や実機で確認した人（`verified`）」を分けて記録し、信頼段階を判断できるようにする |
| `sources` | 参照元リソース | 記事や定義の根拠となる公式ドキュメントURLや更新日時を紐付ける |
| `Attested Computation` | 確定的な計算手順 | AIに数値を推測させないよう、公式な算出手順・クエリ・検証方法そのものを知識タイプとして定義する |

特に秀逸だと感じたのが、**`generated`と`verified`を意図的に分けている点**、そして **`stale_after`を絶対日時で持つ点** です。
AIが生成しただけの記事と、一次ドキュメントや実機テストと照合して確認した記事を機械的に区別でき、しかもcronやCIで日付を比較するだけで「いま見直すべき記事」を洗い出せます。

### AGENTS.mdやllms.txtとの違い

AI向けのファイル規約としては、`AGENTS.md`や`llms.txt`も広く使われています。
これらとOKFは競合するものではなく、それぞれ役割が明確に分かれています。

| 形式 | 主な対象・役割 | イメージ |
| --- | --- | --- |
| `AGENTS.md` / `CLAUDE.md` | コーディング規約やビルド手順など、AIへの**ルール・指示書** | チームの開発マニュアル |
| `llms.txt` | WebサイトがLLM向けに公開する**1枚の案内板**（概要と主要URL一覧） | サイトのインフォメーションボード |
| **OKF** | 体系化された**知識ベースそのもの**と、その信頼・鮮度メタデータ | 分類・目次・有効期限付きの書庫 |

これらを組み合わせることで、「`AGENTS.md`やスキルで作業手順を指示し、OKFで整理された知識ベースを段階的に読み書きする」という連携が自然に成立します。

---

## なぜこの技術ブログにOKFを導入したのか

OKFの仕組みを知ったとき、真っ先に「これは自分の個人ブログの悩みにそのまま使えるのではないか」と思いました。

### 600以上の記事が抱えていた2つの課題

このブログ（晴耕雨読）はGitHub Pages上のJekyllサイトとして運用しており、2016年からの蓄積で**600本以上**（約30カテゴリ）の記事があります。
長く書き続けてきた結果、次の2つの課題を抱えていました。

1. **過去記事の「サイレント陳腐化」**:
   CentOS 7時代のサーバ構築手順や古いAWS CLI・ツール導入記事のように時間経過で古くなる記事と、RSA暗号や剰余演算の数学記事のように何年経っても価値が変わらない記事が、ブログ上ではどれも同じ「公開記事」として並んでいます。どの記事を再点検すべきかを人間がすべて覚えておくのは困難です。
2. **AIに運用を任せようにも全体像を渡せない**:
   これまでも[スキル共有の記事](../misc/share-agent-skills)や[AIとブログ執筆の記事](../misc/blog-writing-and-ai)で触れてきたとおり、AIを思考や執筆のパートナーとして活用したいと考えていました。しかしこれだけ記事数が増えてくると、AIに「過去記事と重複しないよう調べて新しい記事を書いて」「古くなった記事を更新して」と頼んでも、全ディレクトリを`grep`したり大量のファイルを開いたりで手間とコンテキストを消費してしまいます。

### JekyllとOKFの相性の良さ

見方を変えると、Jekyllの記事ファイルは最初から **「YAMLフロントマター ＋ Markdown本文」** という構造を持っています。
データベースへのエクスポートやツールの乗り換えをしなくても、既存の`_posts/`配下にあるフロントマターにOKFメタデータを補い、探索用の`index.md`と`log.md`を添えるだけで、ブログ全体をそのままOKF v0.2のKnowledge Bundleとして扱えるようになります。

---

## 本ブログへの適用設計と工夫したポイント

ここからは、実際にこのリポジトリへOKF v0.2を導入した際の設計と、適用してみて気づいたポイントを紹介します。

### 1. Jekyll公開サイトとOKFバンドルの共存

最初に気になったのが「ルートや`_posts/`の各フォルダに`index.md`や`log.md`、`AGENTS.md`を置いたら、Jekyllのビルド結果が壊れたり、トップページの`index.html`が上書きされたりしないか」という点でした。

確認したところ、Jekyllの投稿読み込み処理はファイル名が`YYYY-MM-DD-*`形式のものだけを記事として扱うため、`_posts/`配下に置いた`index.md`はビルド対象から自然に無視されます。
そのうえで、ルートに配置したファイル群は`_config.yml`の`exclude:`に追加しました。

```yaml
exclude:
  - .agents
  - .claude
  - AGENTS.md
  - CLAUDE.md
  - index.md
  - log.md
  - scripts
```

これにより、AIエージェントやGitHub上でリポジトリを開いたときにはOKFバンドルとして機能しつつ、公開されるトップページやRSSフィード（`feed.xml`）には一切影響を与えずに共存できています。

### 2. 既存記事へのメタデータ設計と「誠実な来歴管理」

既存のすべての記事に対して、本文の内容とgit履歴（`git log --follow`）をもとにメタデータを整理しました。

- **`type`と`tags`の整理**:
  記事の性質に合わせて7種類（`How-To`, `Concept`, `Reference`, `Essay`, `Troubleshooting`, `Book Chapter`, `Template` — 過半数は`How-To`）に分類し、従来のスペース区切りだったタグもYAMLリスト形式に統一しました。
- **技術の寿命に合わせた`stale_after`の設計**:
  一律に期限を付けるのではなく、技術領域ごとに再確認周期を分けています。
  - **1年後**: AI / LLM、クラウド（AWSなど）、Python / Ruby / JavaScriptのパッケージ手順、セキュリティ脆弱性対応など変化の速い記事
  - **3年後**: Linux / SELinux、Git、LaTeX、PowerShell、ネットワークプロトコルなど比較的安定した記事
  - **設定しない（省略）**: 純粋数学、暗号理論の数学的証明、エッセイ・振り返り、および`draft`記事

  この基準で**500本以上**に`stale_after`を設定したところ、導入時点（2026年11月）のチェックで**200本以上**の期限切れ候補（たとえばCentOS 7向けGitサーバ構築やBasicTeX 2019導入手順など）が即座にリストアップされました。長年気になっていた「メンテナンス対象リスト」が数秒で手に入ったのは大きな収穫です。
- **未検証記事に`verified`を捏造しない**:
  初回整備では、過去の`git log`から客観的に追える作成時刻・作成者だけを`generated`に記録し、`verified`はあえて空にしました。本当に公式ドキュメントや実機で再確認した記事だけに`verified`を記録することで、AIが未確認の古い記事を「検証済み」と誤認するのを防げます。

### 3. 既存テーマとの干渉とバリデータでのガード

全記事へメタデータを一括適用する中で、静的サイトジェネレータならではの注意点も見つかりました。

- **`description`内のHTML / Liquid安全文字**:
  このブログのテンプレート（`head.html`や`ogp.html`）では、`page.description`が`<meta name="description" content="...">`にそのまま展開されます。Makefileの自動変数に関する記事の要約に`$<`のような記号が入ったり、ASCIIの二重引用符`"`が入ったりするとHTML属性が壊れてしまうため、これらの文字が含まれていないかを検証スクリプトでチェックするようにしました。
- **URLフラグメント（`#`）のYAMLクォート**:
  本文から外部リンクを抽出して**300本以上**の記事に`sources`を付与した際、URLに`#section`を含むものがそのまま書かれるとYAMLパーサにコメントと誤認されるおそれがあるため、適切に引用符で囲むようにしました。

### 4. AIが自動保守・自動執筆するためのツールとワークフロー

OKFメタデータを揃えただけでは、日々の運用までは回りません。
そこで、メンテナンス作業とAIエージェントの作業を繋ぐために、次の4点をセットで整備しました。

1. **共通ルールとエージェントスキル**:
   [以前紹介した方式](../misc/share-agent-skills)に従い、`AGENTS.md`（＋`CLAUDE.md`のシンボリックリンク）にブログ規約と執筆ポリシーを定義し、`.agents/skills/`（＋`.claude/skills/`のシンボリックリンク）へ3つの共通スキルを配置しました。
   - `okf-maintain-blog`: `stale_after`が切れた記事を抽出し、一次情報を調査して記事本文・`verified`・`stale_after`・`sources`を最新化する
   - `okf-write-post`: 既存カテゴリの`index.md`で重複を調べたうえで、ブログの文体とOKF v0.2仕様に沿って新規記事を執筆する
   - `okf-sync-validate`: 手動編集後にインデックス同期・変更履歴追記・検証・Jekyllビルドを一括実行する
2. **管理CLI（`scripts/okf.rb`）**:
   Ruby標準ライブラリだけで動く管理スクリプトを用意し、`validate`（仕様・リンク・meta安全性チェック）、`stale`（期限切れ抽出）、`sync-index`（ルートおよび`_posts/`配下の全`index.md`再生成）、`log`（`log.md`への逆時系列追記）を1コマンドで実行できるようにしました。
3. **新規テンプレートスクリプト（`new.sh`）**:
   手動で記事を書き始めるときに使う`./new.sh`もOKF v0.2のフロントマター雛形（`status: draft`など）を生成し、自動で`sync-index`を呼ぶように更新しました。
4. **GitHub Actionsによる定期鮮度チェック**:
   `.github/workflows/okf-freshness-check.yml`により、Push / PR時の自動バリデーションに加え、毎週月曜日に`stale`チェックを実行し、期限切れ記事の一覧をGitHub Issueに自動起票・更新するようにしています。

```text
[毎週月曜 GitHub Actions]
   └─▶ scripts/okf.rb stale で期限切れ記事を抽出 → GitHub Issue を自動更新
           │
           ▼
[AI エージェント + okf-maintain-blog スキル]
   ├─▶ index.md を辿って対象記事だけを読み込む（Progressive Disclosure）
   ├─▶ 一次情報・公式ドキュメントを調査し、本文・verified・stale_after を更新
   └─▶ sync-index / log / validate / jekyll build で整合性を自動保証
```

実は、いま読んでいるこの記事自体も`okf-write-post`スキルを使って執筆した最初の記事です。
書いたあとに`sync-index`や`validate`、Jekyllのビルドチェックまで通して公開しており、AIが執筆したことも`generated.by`にそのまま記録しています。

---

## おわりに：まずはあなたのMarkdownに最小1ステップから

「600以上の記事を一気にOKF対応した」と書くと大掛かりに聞こえるかもしれませんが、本当に伝えたいのは **「最初から完璧を目指す必要はまったくない」** ということです。

OKFの仕様が必須項目を`type`だけにとどめ、`index.md`や信頼シグナルをオプトインにしているのは、既存のリポジトリや個人のメモへ後から少しずつ導入できるようにするためです。
自分のブログや技術メモ、チームの運用ドキュメントを「AIと一緒に育てられる知識ベース」に変える取り組みは、驚くほど小さく始められます。

1. 更新頻度が高い記事やよく参照する手順書を数本だけ選び、フロントマターに`type: How-To`と`stale_after: YYYY-MM-DDT00:00:00Z`を足してみる。
2. ルートフォルダに小さな`index.md`（`okf_version: "0.2"`と主要ファイルへのリンク一覧）を置き、AIが全ファイルを読まずに済む地図を作ってみる。
3. 手元のAIエージェント（Claude CodeやCodex、Antigravityなど）に「`index.md`を辿って、`stale_after`が過ぎている記事がないか点検して」と頼んでみる。

それだけで、これまで「書いたら書きっぱなしで、時間とともに静かに風化していくだけ」だったMarkdownのアーカイブが、**AIと人間が共通の地図と鮮度感覚を持って育て続けられる知識ベース**に変わります。

「自分のリポジトリのドキュメント、最近メンテナンスできていないな」と感じているなら、ぜひ今日触っているMarkdownファイルのフロントマターに`type:`を1行足すところから、OKFを試してみてください。

### 参考資料

- [GoogleCloudPlatform/open-knowledge-format (GitHub)](https://github.com/GoogleCloudPlatform/open-knowledge-format)
- [Open Knowledge Format Specification (SPEC.md)](https://github.com/GoogleCloudPlatform/open-knowledge-format/blob/main/SPEC.md)
- [Googleが標準化しようとしているMarkdownの書き方「OKF」って何？（クロイッチチャンネル / YouTube）](https://www.youtube.com/watch?v=Vl6LoetSqEI)
- [LLM Wiki — Andrej Karpathy (GitHub Gist)](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
- [Claude Code・Codex・Antigravityでリポジトリのスキルを共有する](../misc/share-agent-skills)
