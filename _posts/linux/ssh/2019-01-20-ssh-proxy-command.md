---
layout:        post
title:         "踏み台サーバ経由の多段SSH"
date:          2019-01-20
category:      Linux
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from: /shell/ssh-proxy-command
comments:      true
published:     true
---

2つのリモートサーバ hostA、hostB があって、ローカル環境から hostA 経由で hostB にアクセスする多段SSHをする時の ~/.ssh/config の設定について説明します。

~/.ssh/config の設定ファイルに以下を追加することで、「ローカル => hostA => hostB」の接続ができるようになります。

```bash
$ vi ~/.ssh/config

Host hostA
  HostName 127.0.0.1
  User root

Host hostB
  HostName 192.168.1.2
  User root
  ProxyCommand ssh -W %h:%p hostA
```

「ローカル => hostA => hostB」の多段SSH接続ができるかの確認は以下のコマンドを実行します。

```bash
$ ssh hostB
```

以上です。
