---
layout:        post
title:         "CMS管理者ログインページへのアクセスを接続元IPで制限する"
date:          2021-12-08
category:      Linux
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
syntaxhighlight: true
# sitemap: false
# feed:    false
---

管理者ページについて、WordPressは「/wp-admin」、EC-CUBEでは「/admin」、DBにWebでアクセスできるページは「/phpmyadmin」などのように、管理者ページのURLには「admin」が含まれていることが多いです。
通常、管理者ページは管理者IP以外はアクセスできないようにします。

アクセスするURLのパスやファイル名に「admin」が含まれる場合に、アクセスをIPで制限するには、Apache の LocationMatch を使って以下の設定ファイルを /etc/httpd/conf.d の下に配置して Apache を再起動します。
```bash
~]# cat <<EOS > /etc/httpd/conf.d/my-admin-blocker.conf
<LocationMatch "admin">
  Order Deny,Allow
  Deny from All
  Allow from 192.168.0.0/24
</LocationMatch>
EOS
~]# systemctl restart httpd
```
検証用に、Apacheのドキュメントルートに admin を含むディレクトリやパスを以下のように配置しておきます。
```bash
~]$ find /var/www/html -type f
/var/www/html/shop/admin/html/index.html
/var/www/html/shop/admin/index.html
/var/www/html/shop/index.html
/var/www/html/test/wp-admin/html/index.html
/var/www/html/test/wp-admin/index.html
/var/www/html/test/index.html
/var/www/html/wp-admin.php
```
192.168.0.0/24以外からアクセスしてみて、「admin」をパスやファイル名に含む場合は403でアクセス拒否されるようになります。
```bash
~]# curl 127.0.0.1/shop/
shop

~]# curl 127.0.0.1/shop/admin/
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>403 Forbidden</title>

~]# curl 127.0.0.1/shop/admin/html/
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>403 Forbidden</title>

~]# curl 127.0.0.1/test/
test

~]# curl 127.0.0.1/test/wp-admin/
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>403 Forbidden</title>

~]# curl 127.0.0.1/test/wp-admin/html/
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>403 Forbidden</title>

~]# curl 127.0.0.1/wp-admin.php
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>403 Forbidden</title>
```
以上です。

#### 参考文献
- [\<LocationMatch> ディレクティブ - Apache HTTP サーバ バージョン 2.4](https://httpd.apache.org/docs/2.4/ja/mod/core.html#locationmatch)
