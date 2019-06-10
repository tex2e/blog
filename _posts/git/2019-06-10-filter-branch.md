---
layout:        post
title:         "Gitの履歴からファイルを完全に削除する"
menutitle:     "Gitの履歴からファイルを完全に削除する"
date:          2019-06-10
tags:          Git
category:      Git
author:        tex2e
cover:         /assets/cover1.jpg
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
