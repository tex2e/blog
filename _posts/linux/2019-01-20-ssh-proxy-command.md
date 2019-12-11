---
layout:        post
title:         "踏み台サーバ経由の多段SSH"
date:          2019-01-20
category:      Linux
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from: /shell/ssh-proxy-command
comments:      true
published:     true
---

2つのリモートサーバ hostA、hostB があって、
ローカル環境から hostA 経由で hostB にアクセスする多段SSHをする時の ~/.ssh/config の設定。
これで「ローカル => hostA => hostB」の接続ができるようになる。

```command
$ vi ~/.ssh/config

Host hostA
  HostName 127.0.0.1
  User root

Host hostB
  HostName 192.168.1.2
  User root
  ProxyCommand ssh -W %h:%p hostA
```

Micro Hardening などで踏み台サーバ経由でプレイヤーサーバにログインして、
ログファイルなどを手元の環境に保存したいときなどに使える
（Micro Hardening では 45 分の 1 セットごとにプレイヤーサーバがリセットされるので）。

「ローカル => hostA => hostB」の多段SSH接続の確認方法：

```command
$ ssh hostB
```
