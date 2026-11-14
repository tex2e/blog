---
layout:        post
title:         "[Vim] 一括置換をする方法"
type:          How-To
description:   "Vimのコマンドモードで:%s/による全行一括置換や末尾cフラグを用いた対話的確認付き置換を行うコマンド書式と各指定文字の意味を解説。"
tags:          [shell, vim, regex]
status:        stable
stale_after:   2027-07-28T00:00:00Z
generated:
  by:          human:tex2e
  at:          2023-11-17T13:34:20Z
date:          2023-11-17
category:      Shell
cover:         /assets/cover14.jpg
redirect_from: /linux/vim-substitute
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Vimで一括置換するにはコマンドモードで `:%s/` から始まる以下のコマンドを実行します。

```
:%s/置換前/置換後/g
```

置換する際に一つずつ確認して、置換したい時は「y」、したくない時は「n」とするには末尾に `c` を追加した以下のコマンドを実行します。

```
:%s/置換前/置換後/gc
```

- 各命令の意味：
  - `%` : ファイル全体を対象とする
  - `s` : 置換する
  - `g` : 行にある全てのマッチした文字列を置換する
  - `c` : マッチした文字列を1つずつ確認しながら置換する

以上です。
