---
layout:        post
title:         "SageMathをUbuntu 16.04にインストール"
type:          How-To
description:   "Ubuntu 16.04へPPA経由でSageMathをインストールし、暗いターミナル向けにコンソール配色を変更する手順を解説。"
tags:          [crypto, sagemath, ubuntu, installation]
status:        stable
stale_after:   2024-09-10T00:00:00Z
generated:
  by:          human:tex2e
  at:          2019-08-11T02:24:59Z
sources:
  - id:        ref-1
    resource:  https://web.archive.org/web/20210816123743/https://www.unixmen.com/install-sage-on-ubuntu/
    title:     "How to install mathematical application Sage on Ubuntu Linux \\| Unixmen"
  - id:        ref-2
    resource:  https://ask.sagemath.org/question/10060/sage-terminal-colors/
    title:     "sage terminal colors - ASKSAGE: Sage Q&amp;A Forum"
date:          2019-08-11
category:      Crypto
author:        tex2e
cover:         /assets/cover4.jpg
redirect_from: /linux/install-sage-on-ubuntu
comments:      true
published:     true
---

SageMath (セイジ) とは数学の幅広い処理を行うソフトウェアのことです。
暗号をやっている者としては、このソフトを持ち歩いて、いつでも楕円曲線に関する計算をできるようにしておきたいものです。
それでは、このソフトをUbuntu 16.04にインストールする手順を説明します。

### Sage のインストール

以下のコマンドを入力すると Sage の PPA が apt パッケージ管理システムに追加されるので、sage コマンドが使えるようになります[^unixmen]。

```bash
$ sudo apt-add-repository ppa:aims/sagemath
$ sudo apt-get update
$ sudo apt-get install sagemath-upstream-binary
```

### Sage のコンソールの色変更

このままでも sage を使うことはできますが、sage のコンソールの色が背景色が明るいことを前提に作られているので、文字の色が全体的に暗く、Linuxではとても使いやすいとはいえないので、コンソールの色を変更します。

やりかたは、`~/.sage/init.sage` というファイルを作成して、次の一行を加えます。

```
%colors Linux
```

こうすることで、Linuxの背景色が暗いターミナル向けにコンソールの色が調整されます[^asksagemath]。


追記：[SageMathをUbuntu 20.04にインストール](./install-sage-on-ubuntu20.04)

-----

[^unixmen]: [How to install mathematical application Sage on Ubuntu Linux \| Unixmen](https://web.archive.org/web/20210816123743/https://www.unixmen.com/install-sage-on-ubuntu/)
[^asksagemath]: [sage terminal colors - ASKSAGE: Sage Q&amp;A Forum](https://ask.sagemath.org/question/10060/sage-terminal-colors/)
