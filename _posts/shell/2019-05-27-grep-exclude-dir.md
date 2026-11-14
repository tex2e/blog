---
layout:        post
title:         "grepコマンドで特定のディレクトリを検索対象から除外する"
type:          How-To
description:   "grep -rで.gitなどの特定ディレクトリや*.min.jsのようなファイルを検索対象から除外するための--exclude-dirと--excludeの使い方を解説します。"
tags:          [shell, grep, linux, cli]
status:        stable
stale_after:   2026-08-22T00:00:00Z
generated:
  by:          human:tex2e
  at:          2019-05-27T08:49:09Z
date:          2019-05-27
category:      Shell
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
---

gitレポジトリを含むディレクトリで、grep -r による検索を行うと、`.git/` 以下のファイルにも検索が入って、実行速度に影響する場合があるので、grepコマンドで特定のディレクトリを検索対象から除外する方法について説明します。

### \--exclude-dir を使う

特定のディレクトリを検索対象から除外するには `--exclude-dir <path>` と書けば良いです。
.git/ ディレクトリを除外したければ \--exclude-dir .git と書きます。

```bash
grep -r --exclude-dir .git '検索文字列' .
```

### \--include と \--exclude を組み合わせて使う

grep のファイル除外をする別の方法としては exclude オプションを使います。
例えば、JavaScriptファイル (\*.js) を対象にしたいけど、Minifyしたファイル (\*.min.js) は検索して欲しくない時は次のようにオプションを指定してあげます。

```bash
grep -r "検索文字列" . --include=*.js --exclude=*.min.js
```

以上です。
