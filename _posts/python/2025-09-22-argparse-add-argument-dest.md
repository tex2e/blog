---
layout:        post
title:         "[Python] argparseで引数名とプロパティ名を別名にする方法"
type:          How-To
description:   "Pythonのargparse.add_argumentでdest引数を指定し、コマンドライン引数名とNamespace上のプロパティ名を別名にする方法。"
tags:          [python, argparse, cli]
status:        stable
stale_after:   2028-09-23T00:00:00Z
generated:
  by:          human:tex2e
  at:          2025-09-23T07:04:58Z
date:          2025-09-22
category:      Python
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Python の標準ライブラリ `argparse` を利用すると、コマンドライン引数を簡単に処理できます。
通常、オプション名（例: `--input`）を指定すると、コード上では同じ名前をもとにした属性名（例: `args.input`）で参照します。
しかし、引数名（オプション名）とコード上のプロパティ名を別々に指定することも可能です。
その場合に利用するのが `add_argument` の `dest` 引数です。


## dest 引数でプロパティ名を変更する

`dest` を指定することで、Namespace オブジェクト上の属性名を好きな名前に変更できます。
以下は、destを使ったサンプルコードです。

```python
import argparse

parser = argparse.ArgumentParser()

# 引数名は --in だが、プログラム上では indir でアクセスできる
parser.add_argument(
    "--in",
    dest="indir",
    help="入力フォルダ"
)

args = parser.parse_args()
print(args.indir)   # --in に渡した値がここに入る
```

コマンドライン引数のオプション名と、プログラム上で参照する属性名は一致させる必要はありません。
`add_argument` の `dest` 引数を使えば、任意の名前でプロパティにアクセスできます。
この方法を使えば、Pythonプログラム上ではキーワードで予約語の「in」を引数として受け取りつつ、プログラム内では別の変数名で参照できるようになります。

以上です。
