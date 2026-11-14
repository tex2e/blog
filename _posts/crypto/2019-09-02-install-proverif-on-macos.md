---
layout:        post
title:         "[ProVerif] MacOSにProVerifをインストールする"
type:          How-To
description:   "macOSへHomebrewとOPAMでProVerifをインストールする手順と、lablgtkのlibffiエラー解消法を解説。"
tags:          [crypto, proverif, macos, opam, installation]
status:        stable
stale_after:   2027-08-07T00:00:00Z
generated:
  by:          human:tex2e
  at:          2019-09-02T10:37:26Z
sources:
  - id:        ref-1
    resource:  https://prosecco.gforge.inria.fr/personal/bblanche/proverif/manual.pdf
    title:     "ProVerif 2.00: Automatic Cryptographic Protocol Verifier, User Manual and Tutorial"
  - id:        ref-2
    resource:  https://prosecco.gforge.inria.fr/personal/bblanche/proverif/
    title:     "ProVerif: Cryptographic protocol verifier in the formal model"
  - id:        ref-3
    resource:  http://lablgtk.forge.ocamlcore.org/
    title:     "LablGtk is an OCaml interface to GTK+ 1.2, 2.x, and 3.x."
  - id:        ref-4
    resource:  https://github.com/lovell/sharp/issues/1603
    title:     "Package libffi was not found in the pkg-config search path #1603"
date:          2019-09-02
category:      Crypto
author:        tex2e
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
---

セキュリティプロトコルを形式検証する ProVerif を MacOS にインストールする方法について説明します。
ProVerifはOPAM経由でインストールするのが楽だと思いますので、まず始めに、必要なパッケージをインストールします。

```bash
$ brew install ocaml opam graphviz gtk+
```

OPAMの初期化と、最新版のProVerifをインストールできるようにupdateをしておきます。

```bash
$ opam init
$ opam update
```

OPAM経由でProVerifをインストールします。

```bash
$ opam depext conf-graphviz
$ opam depext proverif
$ opam install proverif
```

しかし、proverif の依存である lablgtk ライブラリをインストールするときに失敗しました。

```bash
$ opam install proverif
The following actions will be performed:
  ∗ install ocamlbuild 0.14.0 [required by proverif]
  ∗ install conf-m4    1      [required by ocamlfind]
  ∗ install ocamlfind  1.8.1  [required by proverif]
  ∗ install lablgtk    2.18.8 [required by proverif]
  ∗ install proverif   2.00
===== ∗ 2 =====
Do you want to continue? [Y/n] y

<><> Gathering sources ><><><><><><><><><><><><><><><><><><><><><><><><><><>  🐫
[lablgtk.2.18.8] found in cache
[proverif.2.00] found in cache

<><> Processing actions <><><><><><><><><><><><><><><><><><><><><><><><><><>  🐫
[ERROR] The compilation of lablgtk failed at
        "~/.opam/opam-init/hooks/sandbox.sh build ./configure --prefix
        ~/.opam/default LABLGLDIR=~/.opam/default/lib/lablgl".

#=== ERROR while compiling lablgtk.2.18.8 =====================================#
# context     2.0.5 | macos/x86_64 | ocaml-system.4.08.1 | https://opam.ocaml.org#e2c5fda1
# path        ~/.opam/default/.opam-switch/build/lablgtk.2.18.8
# command     ~/.opam/opam-init/hooks/sandbox.sh build ./configure --prefix
#             ~/.opam/default LABLGLDIR=~/.opam/default/lib/lablgl
# exit-code   1
# env-file    ~/.opam/log/lablgtk-48604-865888.env
# output-file ~/.opam/log/lablgtk-48604-865888.out
### output ###
# [...]
# checking for suffix of object files... o
# checking whether we are using the GNU C compiler... yes
# checking whether clang accepts -g... yes
# checking for clang option to accept ISO C89... none needed
# checking whether C compiler accepts -fno-unwind-tables... yes
# checking platform... Unix
# checking native dynlink... checking for pkg-config... /usr/local/bin/pkg-config
# checking for GTK+ - version >= 2.0.0... no
# *** Could not run GTK+ test program, checking why...
# *** The test program failed to compile or link. See the file config.log for the
# *** exact error that occured. This usually means GTK+ is incorrectly installed.
# configure: error: GTK+ is required


<><> Error report <><><><><><><><><><><><><><><><><><><><><><><><><><><><><>  🐫
┌─ The following actions failed
│ λ build lablgtk 2.18.8
└─
╶─ No changes have been performed

<><> lablgtk.2.18.8 troubleshooting <><><><><><><><><><><><><><><><><><><><>  🐫
=> This package requires gtk+ 2.0 development packages installed on your system
=> To solve pkg-config issues, you may need to do
   'export PKG_CONFIG_PATH=/opt/X11/lib/pkgconfig' and retry

The packages you requested declare the following system dependencies. Please make sure
they are installed before retrying:
    expat gtk
```

調べてみると ./configure の中では pkg-config を使ってライブラリが存在するかを調べており、
その中で `pkg-config --exists --print-errors gtk+-2.0` をしているのですが、
実行してみると libffi が見つからない点で怒られていました。

```bash
$ pkg-config --exists --print-errors gtk+-2.0
Package libffi was not found in the pkg-config search path.
Perhaps you should add the directory containing 'libffi.pc'
to the PKG_CONFIG_PATH environment variable
Package 'libffi', required by 'gobject-2.0', not found
```

なので、改めて libffi などの必要なパッケージをインストールします。

```bash
$ brew install gobject-introspection libffi
```

さらに、pkg-config の検索パス PKG_CONFIG_PATH に gtk+ と libffi を追加しました。

```bash
$ export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
$ export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/opt/gtk+/lib/pkgconfig
$ export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:/usr/local/opt/libffi/lib/pkgconfig
```

ここで改めて proverif をインストールすると成功しました（🐫 可愛い）。

```bash
$ opam install proverif
The following actions will be performed:
  ∗ install lablgtk  2.18.8 [required by proverif]
  ∗ install proverif 2.00
===== ∗ 2 =====
Do you want to continue? [Y/n] y

<><> Gathering sources ><><><><><><><><><><><><><><><><><><><><><><><><><><>  🐫
[lablgtk.2.18.8] found in cache
[proverif.2.00] found in cache

<><> Processing actions <><><><><><><><><><><><><><><><><><><><><><><><><><>  🐫
∗ installed lablgtk.2.18.8
∗ installed proverif.2.00
Done.
```

実行ファイルは `~/.opam/default/bin/proverif` に配置されます。

```bash
$ ~/.opam/default/bin/proverif -h
~/.opam/default/bin/proverif: unknown option '-h'.
Proverif 2.00. Cryptographic protocol verifier, by Bruno Blanchet,
Vincent Cheval, and Marc Sylvestre
  -test     display a bit more information for debugging
  -in <format>    choose the input format (horn, horntype, spass, pi, pitype)
  -out <format>   choose the output format (solve, spass)
  -o <filename>   choose the output file name (for spass output)
  -lib <filename>   choose the library file (for pitype front-end only)
  -TulaFale <version> indicate the version of TulaFale when ProVerif is used
  inside TulaFale
  -graph      create the trace graph from the dot file in the directory specified
  -commandLineGraph   Define the command for the creation of the graph trace from the dot file
  -gc       display gc statistics
  -color      use ANSI color codes
  -html       HTML display
  -help  Display this list of options
  --help  Display this list of options
```

----

- [ProVerif 2.00: Automatic Cryptographic Protocol Verifier, User Manual and Tutorial](https://prosecco.gforge.inria.fr/personal/bblanche/proverif/manual.pdf)
- [ProVerif: Cryptographic protocol verifier in the formal model](https://prosecco.gforge.inria.fr/personal/bblanche/proverif/)
- [LablGtk is an OCaml interface to GTK+ 1.2, 2.x, and 3.x.](http://lablgtk.forge.ocamlcore.org/)
- [Package libffi was not found in the pkg-config search path #1603](https://github.com/lovell/sharp/issues/1603)
