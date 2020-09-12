---
layout:        post
title:         "SageMathをUbuntu 20.04にインストール"
date:          2020-09-13
category:      Crypto
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
syntaxhighlight: true
# sitemap: false
# feed:    false
---

SageMath を Ubuntu 20.04 にインストールするときに Ubuntu 16.04 での手順でインストールしたらエラーが起きたので、解決する方法について備忘録をまとめます。

まず、Ubuntu 20.04 で Sage の PPA を apt に追加しようとするとエラーになります。

```bash
$ sudo apt-add-repository ppa:aims/sagemath
...
E: The repository 'http://ppa.launchpad.net/aims/sagemath/ubuntu focal Release' does not have a Release file.
N: Updating from such a repository can't be done securely, and is therefore disabled by default.
N: See apt-secure(8) manpage for repository creation and user configuration details.
```

調査したところ、どうやら Ubuntu 18.04 以降は PPA を apt に追加しなくても、SageMath がインストールできるようになったようです！


### Sageインストール

というわけで、Sage の PPA を追加している場合は、削除します。

```bash
$ sudo apt-add-repository -r ppa:aims/sagemath
```

そして、SageMath をインストールします。

```bash
$ sudo apt-get install sagemath
```

依存パッケージの一覧を確認したら、ちゃんとPython3に対応していて、えらい！と思いました。


### Sageのコンソールの色変更

コンソールの色変更は Ubuntu 16.04 のときと同じです。
このままでも sage を使うことはできますが、sage のコンソールの色が背景色が明るいことを前提に作られていて、文字の色が全体的に暗く使いにくいので、sageのコンソールの色を変更します。

やりかたは、~/.sage/init.sage というファイルを作成して、次の一行を加えます。

```
%colors Linux
```

こうすることで、Linuxの背景色が暗いターミナル向けにコンソールの色が調整されます。


それでは、Happy Coding!


### 参照

- [software installation - failing to install sagemath on ubuntu 18.04 LTS - Ask Ubuntu](https://askubuntu.com/questions/1031170/failing-to-install-sagemath-on-ubuntu-18-04-lts)
- [SageMathをUbuntu 16.04にインストール](install-sage-on-ubuntu)
- [sage terminal colors - ASKSAGE: Sage Q&A Forum](https://ask.sagemath.org/question/10060/sage-terminal-colors/)
