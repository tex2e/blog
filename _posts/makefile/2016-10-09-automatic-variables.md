---
layout:        post
title:         "Makefile の特殊変数の一覧"
menutitle:     "Makefile の特殊変数の一覧"
date:          2016-10-09
tags:          Programming Makefile
category:      Makefile
author:        tex2e
cover:         /assets/mountain-alternative-cover.jpg
redirect_from:
comments:      false
published:     true
---

Makefile でよく使う、特別な意味を持つ変数（自動変数）の備忘録。

## $@

ターゲット名

| 変数      | 説明
| :------- | :------------- |
| $@       | ルールのターゲットの名前。$(@) と書いても同じ意味を持つ。
| $(@D)    | ルールのターゲットのディレクトリ名。
| $(@F)    | ルールのターゲットのファイル名。

サンプルコード

```makefile
aaa/bbb/foo:
	@echo $@     # => aaa/bbb/foo
	@echo $(@D)  # => aaa/bbb
	@echo $(@F)  # => foo
```

## $<
依存関係の一番最初の名前。

| 変数      | 説明
| :------- | :------------- |
| $<       | 依存関係の一番最初の名前。$(<) と書いても同じ意味を持つ。
| $(<D)    | 依存関係の一番最初のディレクトリ名。
| $(<F)    | 依存関係の一番最初のファイル名。

```makefile
output/foo: input/bar input/baz
	@echo $<     # => input/bar
	@echo $(<D)  # => input
	@echo $(<F)  # => bar
```

## $?
ターゲットより新しい全ての依存関係の名前のそれぞれの間にスペースを挟んで並べたもの。

| 変数      | 説明
| :------- | :------------- |
| $?       | ターゲットより新しい全ての依存関係の名前。$(?) と書いても同じ意味を持つ。
| $(?D)    | ターゲットより新しい全ての依存関係のディレクトリ名。
| $(?F)    | ターゲットより新しい全ての依存関係のファイル名。

```makefile
output/foo: input/bar input/baz
	@echo $?     # => input/bar input/baz
	@echo $(?D)  # => input input
	@echo $(?F)  # => bar baz
```


## Make の特殊変数

| 変数     | 説明
| :------ | :------------- |
| VPATH   | Directory search path for files not found in the current directory.
| SHELL   | The name of the system default command interpreter, usually /bin/sh. You can set SHELL in the makefile to change the shell used to run recipes.
| MAKE    | The name with which make was invoked. Using this variable in recipes has special meaning.
| MAKELEVEL | The number of levels of recursion (sub-makes).
| MAKEFLAGS | The flags given to make. You can set this in the environment or a makefile to set flags.


## 暗黙ルールで使われている変数

| 変数     | 説明
| :------ | :------------- |
| $(AR)   | Archive-maintaining program; default ‘ar’.
| $(AS)   | Program for compiling assembly files; default ‘as’.
| $(CC)   | Program for compiling C programs; default ‘cc’.
| $(CXX)  | Program for compiling C++ programs; default ‘g++’.
| $(CPP)  | Program for running the C preprocessor, with results to standard output; default ‘$(CC) -E’.
| $(FC)   | Program for compiling or preprocessing Fortran and Ratfor programs; default ‘f77’.
| $(M2C)  | Program to use to compile Modula-2 source code; default ‘m2c’.
| $(PC)   | Program for compiling Pascal programs; default ‘pc’.
| $(CO)   | Program for extracting a file from RCS; default ‘co’.
| $(GET)  | Program for extracting a file from SCCS; default ‘get’.
| $(LEX)  | Program to use to turn Lex grammars into source code; default ‘lex’.
| $(YACC) | Program to use to turn Yacc grammars into source code; default ‘yacc’.
| $(LINT) | Program to use to run lint on source code; default ‘lint’.
| $(MAKEINFO) | Program to convert a Texinfo source file into an Info file; default ‘makeinfo’.
| $(TEX)      | Program to make TeX DVI files from TeX source; default ‘tex’.
| $(TEXI2DVI) | Program to make TeX DVI files from Texinfo source; default ‘texi2dvi’.
| $(WEAVE)    | Program to translate Web into TeX; default ‘weave’.
| $(CWEAVE)   | Program to translate C Web into TeX; default ‘cweave’.
| $(TANGLE)   | Program to translate Web into Pascal; default ‘tangle’.
| $(CTANGLE)  | Program to translate C Web into C; default ‘ctangle’.
| $(RM)   | Command to remove a file; default ‘rm -f’.


## 参照

https://www.gnu.org/software/make/manual/make.html
