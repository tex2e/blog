---
layout:        post
title:         "Rocky Linux で hostnamectl コマンドでサーバ名を変更する"
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
