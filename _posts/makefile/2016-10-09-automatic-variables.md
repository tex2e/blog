---
layout:        post
title:         "Makefile の特殊変数・自動変数の一覧"
date:          2016-10-09
category:      Makefile
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      false
published:     true
---

Makefile でよく使う、特別な意味を持つ変数（自動変数）の備忘録です。
具体的には `$@`, `$<`, `$^`, `$?`, `$+`, `$*` と、暗黙ルールで使われる変数（`$(CXX)`, `$(RM)` など）についてです。

## $@

ターゲット名。

| 変数      | 説明
| :------- | :------------- |
| \$@      | ルールのターゲットの名前。\$(@) と書いても同じ意味を持つ。
| \$(@D)   | ルールのターゲットのディレクトリ名。
| \$(@F)   | ルールのターゲットのファイル名。

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
| \$<      | 依存関係の一番最初の名前。\$(<) と書いても同じ意味を持つ。
| \$(<D)   | 依存関係の一番最初のディレクトリ名。
| \$(<F)   | 依存関係の一番最初のファイル名。

```makefile
output/foo: input/bar input/baz
	@echo $<     # => input/bar
	@echo $(<D)  # => input
	@echo $(<F)  # => bar
```

## \$^
ターゲットの全ての依存関係の名前。

| 変数      | 説明
| :------- | :------------- |
| \$^      | ターゲットの依存関係の名前。\$(^) と書いても同じ意味を持つ。
| \$(^D)   | ターゲットの依存関係のディレクトリ名。
| \$(^F)   | ターゲットの依存関係のファイル名。

```makefile
output/foo: input/bar input/baz
	@echo $^     # => input/bar input/baz
	@echo $(^D)  # => input input
	@echo $(^F)  # => bar baz
```

## \$?
ターゲットより**タイムスタンプが新しい**依存関係の名前。

| 変数      | 説明
| :------- | :------------- |
| \$?      | ターゲットより新しい全ての依存関係の名前。\$(?) と書いても同じ意味を持つ。
| \$(?D)   | ターゲットより新しい全ての依存関係のディレクトリ名。
| \$(?F)   | ターゲットより新しい全ての依存関係のファイル名。

```makefile
# ファイル foo よりも bar の方がタイムスタンプが新しく、
# ファイル foo よりも baz の方がタイムスタンプが古い、という状況のとき
output/foo: input/bar input/baz
	@echo $?     # => input/bar
	@echo $(?D)  # => input
	@echo $(?F)  # => bar
```

## \$+
ターゲットの全ての依存関係の名前 (重複があっても省略しない)。
一般的には \$^ の方がよく使われます。

| 変数      | 説明
| :------- | :------------- |
| \$+      | 重複を含むターゲットの依存関係の名前。\$(+) と書いても同じ意味を持つ。
| \$(+D)   | 重複を含むターゲットの依存関係のディレクトリ名。
| \$(+F)   | 重複を含むターゲットの依存関係のファイル名。

```makefile
output/foo: input/baz input/baz input/baz
	@echo $+     # => input/baz input/baz input/baz
	@echo $(+D)  # => input input input
	@echo $(+F)  # => baz baz baz
```

## \$\*

ターゲットのパターンマッチに一致した部分。
関連するファイルを作成するときなどに役立つ。

| 変数      | 説明
| :------- | :------------- |
| \$\*      | ターゲットのパターンマッチに一致した部分。\$(\*) と書いても同じ意味を持つ。
| \$(\*D)   | ターゲットのパターンマッチに一致した部分のディレクトリ名。
| \$(\*F)   | ターゲットのパターンマッチに一致した部分のファイル名。

```makefile
# ファイル lib/foo.c があって `make lib/foo.o` をする状況のとき
%.o: %.c
	@echo $*     # => lib/foo
	@echo $(*D)  # => lib
	@echo $(*F)  # => foo
```



<br>

## Make の特殊変数

| 変数     | 説明
| :------ | :------------- |
| $(VPATH)   | Directory search path for files not found in the current directory.
| $(SHELL)   | The name of the system default command interpreter, usually /bin/sh. You can set SHELL in the makefile to change the shell used to run recipes.
| $(MAKE)    | The name with which make was invoked. Using this variable in recipes has special meaning.
| $(MAKELEVEL) | The number of levels of recursion (sub-makes).
| $(MAKEFLAGS) | The flags given to make. You can set this in the environment or a makefile to set flags.


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
| $(RM)       | Command to remove a file; default ‘rm -f’.

### 追加の引数

| 変数     | 説明
| :------ | :------------- |
| $(ARFLAGS) | Flags to give the archive-maintaining program; default ‘rv’.
| $(ASFLAGS) | Extra flags to give to the assembler (when explicitly invoked on a ‘.s’ or ‘.S’ file).
| $(CFLAGS)  | Extra flags to give to the C compiler.
| $(CXXFLAGS) | Extra flags to give to the C++ compiler.
| $(COFLAGS) | Extra flags to give to the RCS co program.
| $(CPPFLAGS) | Extra flags to give to the C preprocessor and programs that use it (the C and Fortran compilers).
| $(FFLAGS) | Extra flags to give to the Fortran compiler.
| $(GFLAGS) | Extra flags to give to the SCCS get program.
| $(LDFLAGS) | Extra flags to give to compilers when they are supposed to invoke the linker, ‘ld’, such as -L. Libraries (-lfoo) should be added to the LDLIBS variable instead.
| $(LDLIBS) | Library flags or names given to compilers when they are supposed to invoke the linker, ‘ld’. LOADLIBES is a deprecated (but still supported) alternative to LDLIBS. Non-library linker flags, such as -L, should go in the LDFLAGS variable.
| $(LFLAGS) | Extra flags to give to Lex.
| $(YFLAGS) | Extra flags to give to Yacc.
| $(PFLAGS) | Extra flags to give to the Pascal compiler.
| $(RFLAGS) | Extra flags to give to the Fortran compiler for Ratfor programs.
| $(LINTFLAGS) | Extra flags to give to lint.


### 参考文献

- [GNU make： Automatic Variables](https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html)
- [GNU make： Implicit Variables](https://www.gnu.org/software/make/manual/html_node/Implicit-Variables.html)
- [Makefile の関数一覧](https://tex2e.github.io/blog/makefile/functions)
