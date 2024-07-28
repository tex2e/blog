---
layout:        post
title:         "[Windows] バッチのfor文で変数を遅延展開する"
date:          2022-07-09
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

Windowsのバッチファイルにおいて、for文で変数を遅延展開する方法について説明します。

for文内で `%変数名%` を使うと、for文を評価する際に変数展開されるため、繰返し処理しても値は固定になります。
しかし、EnableDelayedExpansion を有効化した上で、「%」を「!」に置き換えて `!変数名!` を使うと、for文の繰返し処理ごとに変数を展開するため、常に変数の最新の値を取得することができます。
遅延変数展開を無効化したい場合は DisableDelayedExpansion にします。

```batch
@echo off

setlocal EnableDelayedExpansion

set COUNTER=123

for %%a in (a,b,c) do (
  echo ---%%a---
  echo 遅延展開なし： %COUNTER%
  echo 遅延展開あり： !COUNTER!

  set /A COUNTER+=1
)

setlocal DisableDelayedExpansion
```

上記プログラムをコマンドプロンプトで実行すると以下のような出力になります。

```output
> test.cmd
---a---
遅延展開なし： 123
遅延展開あり： 123
---b---
遅延展開なし： 123
遅延展開あり： 124
---c---
遅延展開なし： 123
遅延展開あり： 125
```

以上です。



