---
layout:        post
title:         "SSHログインでrootユーザを拒否する"
menutitle:     "SSHログインでrootユーザを拒否する (PermitRootLogin no)"
type:          How-To
description:   "/etc/ssh/sshd_configのPermitRootLoginをnoに設定してsshdを再起動し、SSHによるroot直接ログインを禁止する手順を説明します。"
tags:          [linux, ssh, sshd, hardening]
status:        stable
stale_after:   2025-03-13T00:00:00Z
generated:
  by:          human:tex2e
  at:          2021-11-18T12:42:57Z
date:          2021-11-26
category:      Linux
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

サーバ側でSSHのRootログインを拒否するには sshd の設定ファイル /etc/ssh/sshd_config のパラメータ PermitRootLogin を no に設定します。
```conf
#PermitRootLogin yes
PermitRootLogin no
```
以下のコマンドは、コマンド一発で修正したい人向けです。
```bash
~]# cp /etc/ssh/sshd_config{,.bak} \
 && sed -ie 's/^PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config \
 && grep PermitRootLogin /etc/ssh/sshd_config
~]# systemctl restart sshd
```
sshdサービス再起動後は root でログインできないことを確認してください。

以上です。

