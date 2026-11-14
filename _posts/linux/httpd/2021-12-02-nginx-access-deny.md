---
layout:        post
title:         "Nginxでパスやファイルへのアクセス制限をする"
type:          How-To
description:   "Nginxのlocationディレクティブで正規表現とdeny allやallowを組み合わせ、特定のパスやファイルへのアクセスを制限する方法を解説します。"
tags:          [linux, nginx, access-control, security]
status:        stable
stale_after:   2025-03-13T00:00:00Z
generated:
  by:          human:tex2e
  at:          2021-11-18T12:44:26Z
date:          2021-12-02
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

Nginxでパスやファイルへのアクセス制限をするには location と deny all を使用します。

まず、Nginxの設定ファイル (/etc/nginx/nginx.conf) を編集します。
```bash
~]# vim /etc/nginx/nginx.conf
```

特定のパスへのアクセスを拒否するには、正規表現の使用を表す `~` と先頭マッチの「^」を使って指定します。
```conf
location ~ ^/phpmyadmin/ {
    deny all;
}
```
特定のファイルへのアクセスを拒否するには、正規表現で末尾マッチの「$」を使って指定します。
```conf
location ~ /wp-admin.php$ {
    allow 192.168.0.1;
    deny all;
}
```
設定したらサービス再起動して、対象にアクセスできないこと (403 Forbidden) を確認してください。
```bash
~]# systemctl restart nginx
```
以上です。

