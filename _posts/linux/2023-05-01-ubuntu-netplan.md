---
layout:        post
title:         "Ubuntu22.04で固定IPの設定やDNSの変更をする (netplan)"
date:          2023-05-01
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

Netplan とは Linux のネットワーク設定を YAML ファイルで定義する仕組みです。
Ubuntu 18.04 以降で採用された Netplan を使う場合、/etc/network/interfaces や /etc/resolve.conf を直接書き換えるのは禁止されています。

Netplan を使うことで、静的IPや接続先のDNSの一覧、デフォルトゲートウェイの設定を行うことができます。
設定ファイルは /etc/netplan/ の中に格納されています。

既存の設定ファイルは /etc/netplan/00-installer-config.yaml です。

```yml
network:
  ethernets:
    ens160:
      addresses:
      - 172.17.50.177/20
      nameservers:
        addresses:
          - 172.17.50.22
          - 172.17.50.23
        search: []
      routes:
      - to: default
        via: 172.17.48.1
  version: 2
```

- addresses: で自分自身の静的IPアドレスを指定します。
- nameservers: で接続先DNSサーバの一覧を指定します。
- routes: でデフォルトゲートウェイを指定します。

ファイルを編集したら、以下のコマンドで設定を適用します。

```bash
sudo netplan apply
```

自分自身の静的IPは `ip a` コマンドで確認できます。また、デフォルトゲートウェイは `ip route` コマンドの default 行で確認できます。
DNSは `curl google.com` で名前解決できるかで確認できます。上手くできない場合は、`dig @DNSサーバのIP google.com` でDNSサーバが生きているかを確認してください。

以上です。
