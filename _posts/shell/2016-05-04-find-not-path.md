---
layout:        post
title:         "findコマンドで特定のディレクトリを -not -path で検索対象から除外する"
date:          2016-05-04
category:      Shell
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
---

gitレポジトリを含むディレクトリで、findコマンドを使うと、`.git/` 以下のファイルに検索がマッチして余計な場合があるので、shellのfindコマンドで特定のディレクトリを検索対象から除外する方法について説明します。

-not -path を使う
--------------------

特定のディレクトリを検索対象から除外するには `-not -path <path>` をオプションに追加します。

```shell
find . -name "*" -not -path ".git/*"
```

もし、カレントディレクトリがgitレポジトリではない場合は、gitレポジトリまでのパスを明示的に示すか、ワイルドカード `*` を `.git` の前に置くと良いです。

```shell
find . -name "*" -not -path "path/to/repo/.git/*"
find . -name "*" -not -path "*/.git/*"
```

その他、`-not`は`!`に置き換えることもできます。

```shell
find . -name "*" ! -path "*/.git/*"
```

以上です。
