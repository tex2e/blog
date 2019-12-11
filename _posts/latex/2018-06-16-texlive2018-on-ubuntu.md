---
layout:        post
title:         "texlive2018 on Ubuntu"
date:          2018-06-16
category:      LaTeX
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from: /tex/texlive2018-on-ubuntu
comments:      true
published:     true
---

Ubuntu で texlive2018 にアップデートしたので、その方法についてメモします。

[http://ftp.jaist.ac.jp/pub/CTAN/systems/texlive/tlnet/](http://ftp.jaist.ac.jp/pub/CTAN/systems/texlive/tlnet/)
にアクセスして install-tl.zip をダウンロードする（tl は texlive の略）．

展開し，./install-tl を実行すると選択肢が現れるので，fullは重いのでbasicにするために
S + Enter で set installation scheme を選択する．

```command
$ ./install-tl

======================> TeX Live installation procedure <=====================

======>   Letters/digits in <angle brackets> indicate   <=======
======>   menu items for actions or customizations      <=======

 Detected platform: GNU/Linux on x86_64

 <B> set binary platforms: 1 out of 17

 <S> set installation scheme: scheme-basic

 <C> set installation collections:
     2 collections out of 41, disk space required: 174 MB

 <D> set directories:
   TEXDIR (the main TeX directory):
     /usr/local/texlive/2018
   TEXMFLOCAL (directory for site-wide local files):
     /usr/local/texlive/texmf-local
   TEXMFSYSVAR (directory for variable and automatically generated data):
     /usr/local/texlive/2018/texmf-var
   TEXMFSYSCONFIG (directory for local config):
     /usr/local/texlive/2018/texmf-config
   TEXMFVAR (personal directory for variable and automatically generated data):
     ~/.texlive2018/texmf-var
   TEXMFCONFIG (personal directory for local config):
     ~/.texlive2018/texmf-config
   TEXMFHOME (directory for user-specific files):
     ~/texmf

 <O> options:
   [ ] use letter size instead of A4 by default
   [X] allow execution of restricted list of programs via \write18
   [X] create all format files
   [X] install macro/font doc tree
   [X] install macro/font source tree
   [ ] create symlinks to standard directories

 <V> set up for portable installation

Actions:
 <I> start installation to hard disk
 <P> save installation profile to 'texlive.profile' and exit
 <H> help
 <Q> quit

Enter command: S
```

デフォルトは full になっているので，d + Enter で basic にする（fullだと1GB以上，basicだと174MB）．

```command
===============================================================================
Select scheme:

 a [ ] full scheme (everything)
 b [ ] medium scheme (small + more packages and languages)
 c [ ] small scheme (basic + xetex, metapost, a few languages)
 d [X] basic scheme (plain and latex)
 e [ ] minimal scheme (plain only)
 f [ ] ConTeXt scheme
 g [ ] GUST TeX Live scheme
 h [ ] infrastructure-only scheme (no TeX at all)
 i [ ] teTeX scheme (more than medium, but nowhere near full)
 j [ ] custom selection of collections

Actions: (disk space required: 174 MB)
 <R> return to main menu
 <Q> quit

Enter letter to select scheme: d
Enter letter to select scheme: R
```

インストール時にシンボリックリンクも追加するようにするために，O + Enter で options を選択．

```command
Enter command: O

===============================================================================
Options customization:

 <P> use letter size instead of A4 by default: [ ]
 <E> execution of restricted list of programs: [X]
 <F> create all format files:                  [X]
 <D> install font/macro doc tree:              [X]
 <S> install font/macro source tree:           [X]
 <L> create symlinks in standard directories:  [X]
            binaries to: /usr/local/bin
            manpages to: /usr/local/man
                info to: /usr/local/info

Actions: (disk space required: 5429 MB)
 <R> return to main menu
 <Q> quit

Enter command: L
Enterを三回押すと，デフォルトの場所（/usr/local/binなど）にリンクが作られる
Enter command: R
```

元の画面に戻ったらIでインストール開始

```command
Enter command: I
```

tlmgr を最新にするために，
[http://ftp.jaist.ac.jp/pub/CTAN/systems/texlive/tlnet/](http://ftp.jaist.ac.jp/pub/CTAN/systems/texlive/tlnet/)
にアクセスして update-tlmgr-latest.sh をダウンロードして実行する．

```command
chmod +x update-tlmgr-latest.sh
./update-tlmgr-latest.sh
```

tlmgr を使って必要なパッケージ群をインストール．

```command
sudo tlmgr update --self --all
sudo tlmgr install newtx collection-latexrecommended collection-fontsrecommended collection-langjapanese dvipdfmx
```

インストールしただけではシンボリックリンクが作成されないこともあるので，必要の応じて自分でリンクを貼る．

```command
ln -sf /usr/local/texlive/2018/bin/x86_64-linux/* /usr/local/bin
```

### 補足

自分のところではなぜかtexlive2018に xdvipdfmx がなかったので，texlive2017からコピーしてきたら dvipdfmx が動いた．
ちゃんと日本語を含むtexファイルがpdfに変換されるのを確認してから古いtexliveを消すのが安全．
