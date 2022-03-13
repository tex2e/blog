---
layout:        post
title:         "firewalldでリッチルールを作成・追加する"
date:          2021-11-22
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

firewalldで接続元IPを限定したい場合は、リッチルール (rich rule) を作成します。
ここではfirewalldでリッチルールを作成・追加する方法について説明します。

以下は接続元が IPv4 の 192.168.56.0/24 からで、接続先は 80/tcp のとき通信を許可するルールを追加する方法です。

```bash
~]# firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" source address="192.168.56.0/24" port protocol="tcp" port="80" accept'
~]# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client ssh
  ports:
  protocols:
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
        rule family="ipv4" source address="192.168.56.0/24" port port="80" protocol="tcp" accept

~]# firewall-cmd --runtime-to-permanent
```

削除する際は「--add-rich-rule」を「--remove-rich-rule」に置き換えて実行します。

以上です。
