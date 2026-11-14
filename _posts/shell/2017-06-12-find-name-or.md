---
layout:        post
title:         "findの -or オプションで複数条件の検索"
type:          How-To
description:   "Linuxのfindコマンドで-orオプションを使い、複数のファイル名やディレクトリ名の条件のいずれかに一致する対象を検索する方法を解説します。"
tags:          [shell, linux, find, search]
status:        stable
stale_after:   2026-08-22T00:00:00Z
generated:
  by:          human:tex2e
  at:          2021-10-20T11:53:31Z
date:          2017-06-12
category:      Shell
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Linuxのfindコマンドでファイル名を検索するときに、どちらかの文字列を含む場合にマッチするようにしたいときに使う -or オプションについて説明します。

### -or で複数条件検索

複数の条件でファイル名を検索するときは `-or` オプションを使います。
具体的には `-name 条件1 -or -name 条件2` のように書きます。

```shell
find . -type f -name "*test*" -or -name "*dev*"
```

ディレクトリ名を検索するときは -type d に変えます。

```shell
find . -type d -name "*test*" -or -name "*dev*"
```

以上です。
