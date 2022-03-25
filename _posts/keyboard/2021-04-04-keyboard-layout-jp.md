---
layout:        post
title:         "Kali Linuxでキーボード配列を日本語にする"
date:          2021-04-04
category:      Keyboard
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Kali Linux の設定画面からキーボードレイアウトを「日本語」に設定しても、記号を入力するときに英字配列のままのときの対処法について説明します。

事象としては「X11のキーボードレイアウトは日本語に設定できている」が「仮想コンソールのキーボードレイアウトは設定できていない」という条件だと、日本語配列になりません。

まず、日本語化の手順が全て終わっている状態とします。
また、設定マネージャ > キーボード > レイアウトで「日本語」が設定されている前提です。
（2021/04/06追記：日本語化の手順は必須ではないです。次のlocalectlから設定するだけでよいです）

```bash
# 日本語関連パッケージの導入
$ sudo apt-get install -y task-japanese task-japanese-desktop
# 日本語表示の設定
$ sudo dpkg-reconfigure locales
$ sudo update-locale LANG=ja_JP.UTF-8
# タイムゾーンの設定
$ sudo dpkg-reconfigure tzdata
# 再起動
$ sudo reboot
```

ここで、コンソールで以下を入力してキーボード配列を確認をします。

```bash
$ localectl status
   System Locale: LANG=ja_JP.UTF-8
       VC Keymap: n/a
      X11 Layout: us
       X11 Model: pc105
```

X11 Layout が us だと英字配列になってしまうので修正します。
変更するには、サブコマンド set-keymap を使います。
レイアウト名は「jp106」または「jp-OADG109A」のどちらかを指定します。

```bash
$ sudo localectl set-keymap jp106
$ sudo localectl set-keymap jp-OADG109A
```

実行後に再度statusを表示すると、レイアウトが変更されたことが確認できます。

```bash
$ localectl status
   System Locale: LANG=ja_JP.UTF-8
       VC Keymap: jp106
      X11 Layout: jp
       X11 Model: jp106
     X11 Options: terminate:ctrl_alt_bksp
```

仮想コンソール(VC)とX11の両方に設定されました。
この状態で記号を入力したときに、期待通りの入力ができていればOKです。


### 参考文献

- [Linux - Linux kali CUIでのキーボード配列について｜teratail](https://teratail.com/questions/273602)
