---
layout:        post
title:         "findコマンドで特定のディレクトリを検索対象から除外する"
menutitle:     "findコマンドで特定のディレクトリを検索対象から除外する"
date:          2016-05-04
tags:          Programming Language Bash
category:      Shell
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
---

gitレポジトリを含むディレクトリで、findコマンドを使うと、
`.git/` 以下のファイルに検索が入って実行速度に影響する場合があるので、
shellのfindコマンドで、特定のディレクトリを検索対象から除外する方法について

-not -path を使う
--------------------

特定のディレクトリを検索対象から除外するには`-not -path <path>`を書けば良い。

```shell
find . -name "*" -not -path ".git/*"
```

もし、カレントディレクトリがgitレポジトリではない場合は、
gitレポジトリまでのパスを明示的に示すか、ワイルドカードを`.git`の前に置けば良い。

```shell
find . -name "*" -not -path "path/to/repo/.git/*"
find . -name "*" -not -path "*/.git/*"
```

また、`-not`は`!`に置き換えることもできる

```shell
find . -name "*" ! -path "*/.git/*"
```
