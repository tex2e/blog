---
layout:        post
title:         "Apache/Nginxのサーバ証明書を更新する"
date:          2021-12-15
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

某競技会で証明書期限切れに対応した時の覚書です。

#### 証明書の作成
opensslコマンドで作成します。認証局には証明書署名申請 (csr) ファイルは送り、認証局から証明書 (crt) ファイルを受け取ります。
```bash
~]# openssl genrsa -out server.key 2024
~]# chmod og-r server.key
~]# openssl req -new -key server.key -out server.csr -subj "/C=JP/ST=Tokyo/O=CompanyName/CN=example.com"
# 以下は自己証明書の作成方法
~]# openssl x509 -req -days 365 -signkey server.key -in server.csr -out server.crt
```

#### 証明書の配置場所調査
受け取った証明書は適切な場所に配置します。サービスによって配置する先は異なるので、設定ファイルに書かれてある配置パスを確認します。

ApacheのSSL証明書の配置場所：
```bash
~]# cat /etc/httpd/conf.d/ssl.conf | grep ^SSLCertificate
```
NginxのSSL証明書の配置場所：
```bash
~]# cat /etc/nginx/nginx.conf | grep ssl_certificate
```
その他、証明書の拡張子で設定ファイル内を検索する方法：
```bash
~]# cat /etc/httpd/conf.d/ssl.conf | grep -E 'key$|crt$'
SSLCertificateFile /etc/workspace/srv04.crt
SSLCertificateKeyFile /etc/workspace/srv04.key
```

#### 証明書の配置
ローカル環境で証明書を作成して、それをリモートのサーバに配置する場合、scpで踏み台経由で送信する方法もありますが、拡張子がcrtやkeyのファイルはASCII文字列で構成されているので、普通にコピペでサーバに配置することもできます。
```bash
~]# cat > srv04.crt
証明書crtの内容をコピペ
-----END CERTIFICATE----- までの内容をペーストしたらCtrl+Cで抜ける

~]# cat > srv04.key
秘密鍵keyの内容をコピペ
-----END PRIVATE KEY----- までの内容をペーストしたらCtrl+Cで抜ける
```

以上です。
