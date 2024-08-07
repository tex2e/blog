---
layout:        post
title:         "[ProVerif] MacOS (Monterey) にProVerifをインストールする"
date:          2022-08-10
category:      Crypto
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

macOS MontereyにProVerifをインストールする方法について説明します。
opemでインストールする際に必要なパッケージが存在しない場合はbrewで追加インストールするか聞かれるので、Yを入力すると自動的にインストールされます。

```bash
$ brew install ocaml opam graphviz gtk+
$ opam init
$ opam update
$ opam depext conf-graphviz
$ opam depext proverif
$ opam install proverif
$ which proverif
/Users/mako/.opam/default/bin/proverif
$ proverif --help
Proverif 2.04.
```

以下、実行時のログです。

```
┌──(mako㉿imac)-[~]
└─% brew install ocaml opam graphviz gtk+
...
==> opam
OPAM uses ~/.opam by default for its package database, so you need to
initialize it first by running:

$ opam init

zsh completions have been installed to:
  /opt/homebrew/share/zsh/site-functions

┌──(mako㉿imac)-[~]
└─% opam init
No configuration file found, using built-in defaults.
Checking for available remotes: rsync and local, git.
  - you won't be able to use mercurial repositories unless you install the hg
    command on your system.
  - you won't be able to use darcs repositories unless you install the darcs command
    on your system.


<><> Fetching repository information ><><><><><><><><><><><><><><><><><><><>  🐫
[default] Initialised

<><> Required setup - please read <><><><><><><><><><><><><><><><><><><><><>  🐫

  In normal operation, opam only alters files within ~/.opam.

  However, to best integrate with your system, some environment variables
  should be set. If you allow it to, this initialisation step will update
  your zsh configuration by adding the following line to ~/.zshrc:

    [[ ! -r /Users/mako/.opam/opam-init/init.zsh ]] || source /Users/mako/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null

  Otherwise, every time you want to access your opam installation, you will
  need to run:

    eval $(opam env)

  You can always re-run this setup with 'opam init' later.

Do you want opam to modify ~/.zshrc? [N/y/f]
(default is 'no', use 'f' to choose a different file) no

<><> Creating initial switch 'default' (invariant ["ocaml" {>= "4.05.0"}] - initially with ocaml-system)

<><> Installing new switch packages <><><><><><><><><><><><><><><><><><><><>  🐫
Switch invariant: ["ocaml" {>= "4.05.0"}]

<><> Processing actions <><><><><><><><><><><><><><><><><><><><><><><><><><>  🐫
∗ installed base-bigarray.base
∗ installed base-threads.base
∗ installed base-unix.base
∗ installed ocaml-system.4.12.0
∗ installed ocaml-config.2
∗ installed ocaml.4.12.0
Done.
# Run eval $(opam env --switch=default) to update the current shell environment

┌──(mako㉿imac)-[~]
└─% opam update

<><> Updating package repositories ><><><><><><><><><><><><><><><><><><><><>  🐫
[default] no changes from https://opam.ocaml.org
┌──(mako㉿imac)-[~]
└─% opam depext conf-graphviz

opam depext proverif
opam install proverif
Opam plugin "depext" is not installed. Install it on the current switch? [Y/n] Y
The following actions will be performed:
  ∗ install opam-depext 1.2.1-1

<><> Processing actions <><><><><><><><><><><><><><><><><><><><><><><><><><>  🐫
⬇ retrieved opam-depext.1.2.1-1  (https://opam.ocaml.org/cache)
∗ installed opam-depext.1.2.1-1
Done.

<><> opam-depext.1.2.1-1 installed successfully <><><><><><><><><><><><><><>  🐫
=> opam-depext is unnecessary when used with opam >= 2.1. Please use opam install
   directly instead
# Run eval $(opam env) to update the current shell environment

<><> Carrying on to "opam depext conf-graphviz" <><><><><><><><><><><><><><>  🐫

You are using opam 2.1+, where external dependency handling has been integrated: consider calling opam directly, the 'depext' plugin interface is provided for backwards compatibility only
# Detecting depexts using vars: arch=arm64, os=macos, os-distribution=homebrew, os-family=homebrew
# The following system packages are needed:
graphviz
Allow installing depexts via opam ? [Y/n] Y
You are using opam 2.1+, where external dependency handling has been integrated: consider calling opam directly, the 'depext' plugin interface is provided for backwards compatibility only
# Detecting depexts using vars: arch=arm64, os=macos, os-distribution=homebrew, os-family=homebrew
# The following system packages are needed:
expat
gtk+
pkg-config
Allow installing depexts via opam ? [Y/n] Y

The following system packages will first need to be installed:
    expat

<><> Handling external dependencies <><><><><><><><><><><><><><><><><><><><>  🐫
+ /opt/homebrew/bin/brew "install" "expat"
- ==> Downloading https://ghcr.io/v2/homebrew/core/expat/manifests/2.4.8
- ==> Downloading https://ghcr.io/v2/homebrew/core/expat/blobs/sha256:6c87cbc27a23da1b9c22382d830a3553309bb1475201a375af648941330af9f4
- ==> Downloading from https://pkg-containers.githubusercontent.com/ghcr1/blobs/sha256:6c87cbc27a23da1b9c22382d830a3553309bb1475201a375af648941330af9f4?se=2022-08-10T09%3A45%3A00Z&sig=rlNtikchFQw26jn9LjeP5H4CCHptWCS3cmYY6S%2FxJVE%3D&sp=r&spr=https&sr=b&sv=2019-12-12
           - ==> Pouring expat--2.4.8.arm64_monterey.bottle.tar.gz
                                                                  - ==> Caveats
- expat is keg-only, which means it was not symlinked into /opt/homebrew,
- because macOS already provides this software and installing another version in
- parallel can cause all kinds of trouble.
-
- If you need to have expat first in your PATH, run:
-   echo 'export PATH="/opt/homebrew/opt/expat/bin:$PATH"' >> ~/.zshrc
-
- For compilers to find expat you may need to set:
-   export LDFLAGS="-L/opt/homebrew/opt/expat/lib"
-   export CPPFLAGS="-I/opt/homebrew/opt/expat/include"
-
- For pkg-config to find expat you may need to set:
-   export PKG_CONFIG_PATH="/opt/homebrew/opt/expat/lib/pkgconfig"
-
- ==> Summary
- 🍺  /opt/homebrew/Cellar/expat/2.4.8: 21 files, 599.0KB
The following actions will be performed:
  ∗ install conf-pkg-config 2       [required by conf-gtk2]
  ∗ install ocamlfind       1.9.5   [required by proverif]
  ∗ install conf-gtk2       1       [required by lablgtk]
  ∗ install lablgtk         2.18.12 [required by proverif]
  ∗ install proverif        2.04
===== ∗ 5 =====
Do you want to continue? [Y/n] Y

<><> Processing actions <><><><><><><><><><><><><><><><><><><><><><><><><><>  🐫
∗ installed conf-pkg-config.2
⬇ retrieved ocamlfind.1.9.5  (https://opam.ocaml.org/cache)
∗ installed conf-gtk2.1
⬇ retrieved lablgtk.2.18.12  (https://opam.ocaml.org/cache)
⬇ retrieved proverif.2.04  (https://opam.ocaml.org/cache)
∗ installed ocamlfind.1.9.5
∗ installed lablgtk.2.18.12
∗ installed proverif.2.04
Done.
# Run eval $(opam env) to update the current shell environment

┌──(mako㉿imac)-[~]
└─% proverif --help
Proverif 2.04. Cryptographic protocol verifier, by Bruno Blanchet, Vincent Cheval, and Marc Sylvestre
```

以上です。
