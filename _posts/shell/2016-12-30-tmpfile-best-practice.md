---
layout:        post
title:         "Shellにおける一時ファイルの扱いかた"
menutitle:     "Shellにおける一時ファイルの扱いかた"
date:          2016-12-30
tags:          Programming Language Bash
category:      Shell
author:        tex2e
cover:         /assets/cover2.jpg
redirect_from:
comments:      false
published:     true
---


一時ファイルの作成・削除におけるベストプラクティス
-------------------------

とりあえずよく使う雛形を以下に示す。

```bash
# 一時ファイルを作る
tmpfile=$(mktemp)

# 正常・異常終了時に生成した一時ファイルを削除する
function rm_tmpfile {
  [[ -f "$tmpfile" ]] && rm -f "$tmpfile"
}
trap rm_tmpfile EXIT
trap 'trap - EXIT; rm_tmpfile; exit -1' INT PIPE TERM

# これ以降に tmpfile を使った処理を書く
ls > "$tmpfile"
```


コマンドの説明
-------------------------

### mktemp

まず、mktemp というコマンドだが、これは「一時ファイルとして利用できるファイル名」を返すコマンドである。
つまり、mktemp を実行した時点ではファイルは何一つ作られてはいない。
したがって、mktemp によって得られたファイル名は、変数に保存しておく必要がある。

```bash
tmpfile=$(mktemp)
```

ここでは、tmpfile という変数名に一時ファイルの名前を保存している。


### trap

trap コマンドはシグナルを受け取るための処理を記述するためのコマンドで、いわゆるイベントハンドラである。
具体的には、正常終了した時に送られる EXIT シグナルや、
Ctrl+C で処理が中断された時に送られる INT（interrupt）シグナルなどを捕まえることができる。

例えば、EXIT シグナルが送られた時に goodbye と表示させたければ次のように書く。

```bash
trap 'echo goodbye' EXIT
```

trap の第一引数に実行したいスクリプトを書くのだが、長くなると読みにくいので、関数にまとめてそれを
呼び出すというのが一般的である。
