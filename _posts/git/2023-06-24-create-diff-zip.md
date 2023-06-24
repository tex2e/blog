---
layout:        post
title:         "Gitでブランチ間の差分ファイルだけをZipにする方法"
date:          2023-06-24
category:      Git
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

gitでブランチ間の差分ファイルだけを抽出して、Zipファイルにまとめる方法について説明します。

gitで差分のZipファイルを作るには、`git archive` コマンドを使用します。
使い方は `git archive --output=出力先ファイル名 ブランチ名 ファイル一覧...` です。
また、ブランチ間の差分ファイルの一覧は `git diff --name-only 追加前ブランチ名 追加後ブランチ名` で取得できます。

これらのコマンドを以下のように組み合わせることで、ブランチ間の差分ファイルだけをZipにまとめることができます。

Linuxで実行する場合：
```bash
diff_a="develop"
diff_b="feature/some-feature-abc"
git diff --name-only $diff_a $diff_b
git archive --output="/tmp/diff.zip" $diff_b $(git diff --name-only $diff_a $diff_b)
```

PowerShellで実行する場合：
```powershell
$diff_a="develop"
$diff_b="feature/some-feature-abc"
git diff --name-only $diff_a $diff_b
git archive --output="C:\#tmp\diff.zip" $diff_b $(git diff --name-only $diff_a $diff_b)
```

以上です。
