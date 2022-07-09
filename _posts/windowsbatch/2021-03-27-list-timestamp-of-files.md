---
layout:        post
title:         "サブフォルダも含めた全てのファイルの更新時間を出力"
date:          2021-03-27
category:      WindowsBatch
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Windowsのバッチで、サブフォルダも含めた全てのファイルの更新時間を出力するには、for文と変数展開の形式を指定する `~t` を使います。

Gitで管理していない状態で編集したとき、原本の更新時間一覧とWinMergeなどで比較するときに利用できます。

```batch
@echo off

set OUTPUT=更新時間一覧.txt

type nul > %OUTPUT%
for /r %%a in (*) do echo %%~ta  %%a >> %OUTPUT%
```

以上です。
