---
layout:        post
title:         "Gitでブランチ間の差分ファイルだけをZipにする方法"
type:          How-To
description:   "git diff --name-onlyとgit archiveを組み合わせ、ブランチ間の差分ファイルだけをZip圧縮するLinuxとPowerShellの手順。"
tags:          [git, archive, powershell, linux]
status:        stable
stale_after:   2026-06-24T00:00:00Z
generated:
  by:          human:tex2e
  at:          2023-06-24T10:12:14Z
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
