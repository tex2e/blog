---
layout:        post
title:         "Apacheでパスやファイルへのアクセス制限をする"
date:          2021-12-01
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

Apacheでパスやファイルへのアクセス制限をするときに使う Directory, LocationMatch, FilesMatch について説明します。

/etc/httpd/conf/httpd.conf を編集するか、/etc/httpd/conf.d 直下に設定ファイル myrule.conf を作成します。
```bash
~]# vim /etc/httpd/conf.d/myrule.conf
```
特定のディレクトリ（サーバ上の絶対パス）へのアクセスを拒否するには、Directoryディレクティブを使用します。
```conf
<Directory "/var/www/html/phpmyadmin">
  Require all denied
</Directory>
```
特定のパスへのアクセスを拒否するには、LocationMatchディレクティブを使用します。
```conf
<LocationMatch ^/phpmyadmin/>
  order allow,deny
  deny from all
</LocationMatch>
```
特定のファイルへのアクセスを拒否するには、FilesMatchディレクティブを使用します。
```conf
<FilesMatch "^(wp-admin\.php|xmlrpc\.php)">
  order allow,deny
  allow from 192.168.0.1
  deny from all
</FilesMatch>
```
設定したらサービス再起動して、対象にアクセスできないこと (403 Forbidden) を確認してください。
```bash
~]# systemctl restart httpd
```
以上です。

