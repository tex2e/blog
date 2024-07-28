---
layout:        post
title:         "MacOSのWiresharkが権限エラーでキャプチャできないとき"
date:          2021-10-08
category:      Shell
cover:         /assets/cover14.jpg
redirect_from:
    - /linux/wireshark-permission-error-macos
    - /linux/wireshark-permission-err-macos
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

MacOSのWiresharkでLocalhostの通信をキャプチャするときに、権限エラーで失敗してしまう時の対処方法です。

まず、ローカルの通信をキャプチャしたいので「Loopback: lo0」をクリックすると、ダイアログとともに以下のエラーが表示されます。

**The capture session could not be initiated on interface 'lo0' (You don't have permission to capture on that device).**

<!--
Please check to make sure you have sufficient permissions.

If you installed Wireshark using the package from wireshark.org, close this dialog and click on the "installing ChmodBPF" link in "You can fix this by installing ChmodBPF." on the main screen, and then complete the installation procedure.
-->

エラーの詳細を読むと、対象ファイルへの権限がなく、ChmodBPF をインストールすれば解決するらしいのですが、ここではターミナルのコマンドだけで解決する方法について説明します。
手順としては、以下の通りです。

1. 自身のユーザ名を確認する
2. BPFファイルの所有権を自身に変更する

具体的には、ターミナルで以下のコマンドを入力します。

```bash
$ sudo chown $(whoami):admin /dev/bpf*
$ ls -l | grep /dev/bpf*
```

/dev/bpf0 などのファイルの所有者とグループが変更されたことを確認して、再度 Wireshark で「Loopback: lo0」をパケットキャプチャします。
そうすると、今度はエラーなしでキャプチャを開始できます。

以上です。
