---
layout:        post
title:         "LaTeX の Listing 対応言語一覧"
menutitle:     "LaTeX の Listing 対応言語一覧"
date:          2016-12-05
tags:          Language LaTeX
category:      Misc
author:        tex2e
cover:         /assets/mountain-alternative-cover.jpg
redirect_from:
comments:      false
published:     true
---

Listing が対応している言語の一覧をドキュメント（pdf）から拾ってきたのでメモ。


指定方法
------------

lstset という命令の中で、language = LangName と指定する。

```latex
\lstset{language=C}
```

対応言語一覧
------------

以下に対応言語の一覧を表にまとめた。
バージョンを指定するときは `language=[POSIX]Awk` と書く。
なお、バージョンの中にある太字は、デフォルトで適用される種類である。
例えば、Awk は2つの種類（gnu, POSIT）があるが、`language=Awk` と書いた場合は、
gnu 版の Awk のシンタックスハイライトが適用される。

| 言語     | バージョン
| :------- | :-------
| ABAP | (R/2 4.3, R/2 5.0, R/3 3.1, R/3 4.6C, **R/3 6.10**)
| ACM
| ACMscript
| ACSL
| Ada | (**2005**, 83, 95)
| Algol | (60, **68**)
| Ant
| Assembler | (Motorola68k, x86masm)
| Awk | (**gnu**, POSIX)
| bash
| Basic | (Visual)
| C | (**ANSI**, Handel, Objective, Sharp)
| C++ | (11, ANSI, GNU, **ISO**, Visual)
| Caml | (**light**, Objective)
| CIL
| Clean
| Cobol | (1974, **1985**, ibm)
| Comal 80
| command.com | (**WinXP**)
| Comsol
| csh
| Delphi
| Eiffel
| Elan
| erlang
| Euphoria
| Fortran | (03, 08, 77, 90, **95**)
| GAP
| GCL
| Gnuplot
| hansl
| Haskell
| HTML
| IDL | (*empty*, CORBA)
| inform
| Java | (*empty*, AspectJ)
| JVMIS
| ksh
| Lingo
| Lisp | (*empty*, Auto)
| LLVM
| Logo
| Lua | (5.0, 5.1, 5.2, 5.3)
| make | (*empty*, gnu)
| Mathematica | (1.0, 3.0, **5.2**)
| Matlab
| Mercury
| MetaPost
| Miranda
| Mizar
| ML
| Modula-2
| MuPAD
| NASTRAN
| Oberon-2
| OCL | (decorative, **OMG**)
| Octave
| Oz
| Pascal | (Borland6, **Standard**, XSC)
| Perl
| PHP
| PL/I
| Plasm
| PostScript
| POV
| Prolog
| Promela
| PSTricks
| Python
| R
| Reduce
| Rexx
| RSL
| Ruby
| S | (*empty*, PLUS)
| SAS
| Scala
| Scilab
| sh
| SHELXL
| Simula | (**67**, CII, DEC, IBM)
| SPARQL
| SQL
| tcl | (*empty*, tk)
| TeX | (AlLaTeX, common, LaTeX, **plain**, primitive)
| VBScript
| Verilog
| VHDL | (*empty*, AMS)
| VRML | (**97**)
| XML
| XSLT

いくつかの言語（HTML や XML）のハイライトはまだ完璧ではないらしいので使うときは注意してください。


See Also
------------

[Listings User's Guide](http://texdoc.net/texmf-dist/doc/latex/listings/listings.pdf)
