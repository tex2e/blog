---
layout:        post
title:         "MacからWindowsへRDP接続するとキーボードがJISではなくUS配列になるとき"
date:          2022-08-06
category:      Windows
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Macの「Microsoft Remote Desktop」からWindowsにRDP（リモートデスクトップ）接続する際にキーボードがJIS(日本語)ではなくUS(英語)配列になってしまうときは、Windows側のレジストリを編集すると事象が解消されます。

### 対処方法

接続先のWindowsで以下の作業を行います。

1. Win+R で regedit を入力してレジストリエディタを開き、以下のレジストリを開きます。

   **HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Keyboard Layouts\00000411**

2. Layout File を「KBDJPN.DLL」から「**kbd106.dll**」に書き換えます。

3. MacOSからRDP接続し、日本語キーボードとして認識されているか確認します。

以上です。

### 参考文献
- [Windows 10 RS4 へのリモート デスクトップ接続時に、UWP アプリへの入力時のみキーボード配列が異なる事象について \| Microsoft Docs](https://docs.microsoft.com/ja-jp/archive/blogs/askcorejp/rs4-rdp-keyboardlayout)
- [RDPでキーボードがJISではなくUSになってしまう問題 \| 猫好きが猫以外のことも書く](https://bitto.jp/posts/%E6%8A%80%E8%A1%93/%E3%83%8A%E3%83%AC%E3%83%83%E3%82%B8/rdp-keyboard/)
