---
layout:        post
title:         "Gitの履歴からファイルを完全に削除する"
type:          How-To
description:   "git filter-branchの--index-filterとgit rmを使い、指定したファイルを過去の全コミット履歴から完全に削除する方法。"
tags:          [git, filter-branch, history]
status:        stable
stale_after:   2022-06-10T00:00:00Z
generated:
  by:          human:tex2e
  at:          2019-06-10T10:13:06Z
date:          2019-06-10
category:      Git
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
---

Gitで追加したファイルについて、履歴から削除する方法について説明します。
Gitの履歴からファイルを削除するには `git filter-branch` コマンドを使います。
結論から言うと、次のコマンドを実行すれば履歴から消えます。

```command
git filter-branch --index-filter 'git rm --cached --ignore-unmatch filename' HEAD
```

上の `filename` のところに、消したいファイル名を入れます。
実行すると全コミットに対して、対象のファイルがインデックスに存在する場合は、そのファイルを削除します。

以下オプションの説明です。

#### git filter-branch のオプション

- `--index-filter <cmd>`

    インデックス（コミットするファイルの一覧）を書き換えるためのフィルタを実行します

#### git rm のオプション

- `--cached`

    インデックスに登録されたファイルに対して、削除を行います

- `--ignore-unmatch`

    削除したいファイルが存在しない場合でも、0 (成功) を返します
