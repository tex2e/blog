---
layout:        post
title:         "SSHログインでrootユーザを拒否する"
menutitle:     "SSHログインでrootユーザを拒否する (PermitRootLogin no)"
date:          2021-11-26
category:      Linux
cover:         /assets/cover1.jpg
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

