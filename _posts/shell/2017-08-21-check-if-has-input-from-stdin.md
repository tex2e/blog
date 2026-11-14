---
layout:        post
title:         "Bashでパイプからの入力があるかどうかを確認する方法"
type:          How-To
description:   "Bashスクリプトでtest -p /dev/stdinを使い、パイプやFIFOを通じた標準入力の有無を判定する方法について解説します。"
tags:          [shell, bash, stdin, pipe]
status:        stable
stale_after:   2026-08-22T00:00:00Z
generated:
  by:          human:tex2e
  at:          2017-08-21T09:57:18Z
date:          2017-08-21
category:      Shell
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
---

パイプから入力があるとはどういう状況かというと、
以下のようにパイプ「|」を通して一つ前のコマンドの結果を受け取ることを指す。

```bash
$ cat filename | ./myprogram
```

Bashでパイプからの入力もしくはリダイレクトによる入力があるかを調べるには、
testコマンドの -p オプションを使う。
p はパイプ（Pipe）を意味し、引数のファイルがパイプであるかどうかを調べることができる。

```bash
if [ -p /dev/stdin ]; then
  echo "Input from pipe"
  cat /dev/stdin
else
  echo "No input from pipe"
fi
```

パイプを通してデータが渡されると標準入力として使われる /dev/stdin というファイルはパイプになる。
なお、一般にパイプとして振る舞うファイルのことを **FIFO** という。
すなわち `test -p /dev/stdin` または `[ -p /dev/stdin ]`
は与えられたファイルが FIFO であるかどうかを確認するコマンドである。

ちなみに、そのファイルがパイプかどうかを確認する別の方法としては、
`ls -l` をした時に表示されるファイルモードの頭文字が p となっているファイルは FIFO である [^1]。

-----

[^1]: d はディレクトリ、l はシンボリックリンク、- は普通のファイルの意味である
