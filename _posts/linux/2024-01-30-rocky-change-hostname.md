---
layout:        post
title:         "Rocky Linux で hostnamectl コマンドでサーバ名を変更する"
type:          How-To
description:   "Rocky Linuxでhostnamectl set-hostnameとsystemd-hostnamed再起動によりホスト名を変更し、/etc/hostsを更新する手順を解説します。"
tags:          [linux, rocky-linux, hostname, systemd]
status:        stable
stale_after:   2027-11-28T00:00:00Z
generated:
  by:          human:tex2e
  at:          2024-02-03T12:52:28Z
sources:
  - id:        ref-1
    resource:  https://wiki.crowncloud.net/?How_to_Change_Hostname_in_Rocky_Linux_9
    title:     "CrownCloud Wiki - How To Change Hostname In Rocky Linux 9"
date:          2024-01-30
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

Rocky Linuxでhostnamectlコマンドでサーバのホスト名を変更する方法について説明します。

### hostnamectl

現在のサーバのホスト名は、hostnamectl コマンドで確認することができます。
また、ホスト名を変更するには、hostnamectl set-hostname を実行した後に、systemd-hostnamed デーモンを再起動します。

```bash
~]# hostnamectl set-hostname test.example.com
~]# systemctl restart systemd-hostnamed
```

### /etc/hosts
次に、サーバのホスト名で自分自身にアクセスできるように /etc/hosts を修正します（この修正は不要の場合は実施する必要はありません）。
```bash
~]# vi /etc/hosts
```

```bash
~]$ cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4 test.example.com
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
```
修正すると、ping などでホスト名を指定した際に、自分自身と通信できるようになります。

以上です。

### 参考資料

- [CrownCloud Wiki - How To Change Hostname In Rocky Linux 9](https://wiki.crowncloud.net/?How_to_Change_Hostname_in_Rocky_Linux_9)
