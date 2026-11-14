---
layout:        post
title:         "クロスプラットフォームで make"
type:          How-To
description:   "Makefile内で$(shell uname)の実行結果とifeqディレクティブを使い、macOS・Linux・Cygwinごとに処理を分岐させる方法を説明します。"
tags:          [makefile, gnu-make, cross-platform]
status:        stable
stale_after:   2019-12-05T00:00:00Z
generated:
  by:          human:tex2e
  at:          2016-12-05T14:01:50Z
date:          2016-12-05
category:      Makefile
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from:
comments:      false
published:     true
---

Makefile で OSごとに違う処理を行う方法について。


uname を使う
---------------


uname は OS の名前を表示するためのコマンドです。
これを Makefile から呼び出すには `$(shell uname)` と書きます。
また、Makefile での文字列の比較は、`ifeq` ディレクティブでできます。

```makefile
UNAME := $(shell uname)

ifeq ($(UNAME), Darwin)
# MacOS での処理
LIBS += -framework GLUT -framework OpenGL -lm
else
ifeq ($(UNAME), Linux)
# Linux での処理
LIBS += -lglut -lGL -lGLU -lm
else
# Cygwin での処理
LIBS += -lglut32 -lglu32 -lopengl32 -lm
endif
endif
```
Cygwin で uname すると、いろいろ余分な情報（バージョン番号とか何か）も一緒に表示されるので、
Cygwin の uname を ifeq することはできませんでした。
したがって、この例のように、uname の結果が Darwin でも Linux でもない場合は、Cygwin だと判断しています。
