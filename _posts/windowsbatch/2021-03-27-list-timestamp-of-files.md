---
layout:        post
title:         "サブフォルダも含めた全てのファイルの更新時間を出力"
date:          2021-03-27
category:      WindowsBatch
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
syntaxhighlight: true
# sitemap: false
# feed:    false
---

サブフォルダも含めた全てのファイルの更新時間を出力するコマンド。
Gitで管理していない状態で編集したとき、原本の更新時間一覧とWinMergeなどで比較するときに使う用です。

```batch
@echo off

set OUTPUT=更新時間一覧.txt

type nul > %OUTPUT%
for /r %%a in (*) do echo %%~ta  %%a >> %OUTPUT%
```

以上です。
