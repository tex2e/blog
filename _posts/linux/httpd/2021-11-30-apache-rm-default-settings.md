---
layout:        post
title:         "Apacheで不要な設定ファイルを削除する"
date:          2021-11-30
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

Apacheは設定ファイルを読み込む際に Include で指定されている設定ファイルを読み込みます。
しかし、それらの中にはセキュリティ的に削除すべき設定ファイルも含まれています。

まず、/etc/httpd/conf/httpd.conf の中を確認して、どのフォルダの設定ファイルを読み込んでいるか確認します。
```bash
~]# grep ^Include /etc/httpd/conf/httpd.conf
Include conf.modules.d/*.conf
IncludeOptional conf.d/*.conf
```
セキュリティ的に不要な設定ファイルがいくつか存在するので、それらの設定ファイルは拡張子を変更して、Apacheが読み込まないようにします。
```bash
# iconsディレクトリの無効化
~]# mv /etc/httpd/conf.d/autoindex.conf{,.disabled}
# デフォルトトップページの無効化
~]# mv /etc/httpd/conf.d/welcome.conf{,.disabled}
# Linuxユーザの公開コンテンツの無効化
~]# mv /etc/httpd/conf.d/userdir.conf{,.disabled}

# WebDAVの無効化
~]# mv /etc/httpd/conf.modules.d/00-dav.conf{,.disabled}
# CGIの無効化
~]# mv /etc/httpd/conf.modules.d/01-cgi.conf{,.disabled}

# サービス再起動
~]# systemctl restart httpd
```
以上の設定は削除（リネーム）してもデフォルトでは問題ありません。

以上です。

