---
layout:        post
title:         "入出力リダイレクタでファイルを上書き更新する"
date:          2020-01-04
category:      Shell
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
# sitemap: false
# draft:   true
---

一時ファイルを使わずに、Bashの入出力リダイレクタだけでファイルを上書き更新（置換）する方法について説明します。
上書きするには標準入力と標準出力を同時に使用する `<>` を使って `< ファイル名 1<> ファイル名` を書くことで上書き更新できます。なお `1<> file` はファイルディスクリプタ1の標準入力と標準出力としてfileを使うという意味です。

#### tr で上書きする例

```bash
$ echo "Hello, world\!" > test.txt
$ cat test.txt
Hello, world!
$ tr '\!' '?' < test.txt 1<> test.txt
$ cat test.txt
Hello, world?
```

#### sed で上書きする例

```bash
$ echo "Hello, world\!" > test.txt
$ cat test.txt
Hello, world!
$ sed 's/world/bash/g' < test.txt 1<> test.txt
$ cat test.txt
Hello, bash!
```

補足ですが、sed は `-i` オプションで上書き更新できるので、`<>` を使う必要はありません。

### 考察

`sort < hoge.txt > hoge.txt` のように、存在するファイルに対して入力と出力を同時に行うと、hoge.txt の内容は消えてしまいます。
しかしシェルでは、オープンしたファイルを削除しても、クローズされるまではファイル本体が残っていて、読み書き可能であることを利用した上書き更新に関する黒魔術 `(rm -f hoge.txt && sort > hoge.txt) < hoge.txt` が存在します。
なので `sort < hoge.txt 1<> hoge.txt` でファイルの上書き更新ができるのは、黒魔術のように、サブシェル内で元のファイルを削除するという処理をしているものと推測されます。
しかし、Bashの公式ドキュメントを読んでも `<>` リダイレクタに関する詳細な説明はないので、`<>` を使った上書き更新はあくまで「シェル芸」として節度を持って使うのが良いかと思います。
