---
layout:        post
title:         "Rocky Linux における nmcil によるIPアドレス固定"
date:          2024-01-29
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

Rocky LinuxにおいてnmcliコマンドでIPアドレスを固定化する方法について説明します。

まず、nmcli conn コマンドを使って、接続名を確認します。

```bash
~]# nmcli conn
```
出力例：
```
NAME   UUID                                  TYPE      DEVICE
ens34  4ed2aeab-361d-33d4-8fd4-6d88be4db85c  ethernet  ens34
lo     f706fa18-8bff-4294-8ed5-6b48e74ecfd4  loopback  lo
```

次に、IPアドレスを固定化します。
先に、ipv4.addresses でIPアドレスを指定し、その後に ipv4.method を manual (手動) に設定します。
設定順が逆になるとエラーになります。
設定が終わったら、nmcli conn up で設定を適用させます（nmcil conn down は不要です）。

```bash
~]# nmcli conn mod ens34 ipv4.addresses 192.168.11.190/24
~]# nmcli conn mod ens34 ipv4.method manual
~]# nmcli conn up ens34
```

nmcli で設定した後は、ipv4.method が auto (自動) から manual (手動) に変化し、指定したIPアドレスが表示されます。

```bash
~]# nmcli conn show ens34 | grep -E 'ipv4.method|ipv4.addresses'
```
出力例：
```
ipv4.method:                            manual
ipv4.addresses:                         192.168.11.190/24
```

ip addr コマンドで、実際に割り当てられたIPアドレスを確認して、IPアドレスが変化すれば成功です。

```bash
~]# ip a
```
出力例：
```
2: ens34: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:0c:29:30:b6:86 brd ff:ff:ff:ff:ff:ff
    altname enp2s2
    inet 192.168.11.190/24 brd 192.168.11.255 scope global noprefixroute ens34
       valid_lft forever preferred_lft forever
```

以上です。
