---
layout:        post
title:         "Bashでパイプからの入力があるかどうかを確認する方法"
menutitle:     "Bashでパイプからの入力があるかどうかを確認する方法"
date:          2017-08-21
tags:          Programming Language Shell
category:      Shell
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
---

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

[^1]: dはディレクトリ、lはシンボリックリンク、-は普通のファイルなどの意味を持つ。
