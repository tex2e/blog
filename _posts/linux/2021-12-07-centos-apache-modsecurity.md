---
layout:        post
title:         "CentOSのApacheでModSecurityを動かす"
date:          2021-12-07
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

CentOSにmod_securityをインストールして、ApacheのWAFとして動作させるための方法について説明します。

#### ModSecurityのインストール (yum install)
mod_securityと CRS (Core Rule Set) をインストールします。
```bash
~]# yum install mod_security mod_security_crs
```

#### ModSecurityのインストール (yum localinstall)
本番環境がインターネットへの接続ができない場合は、検証環境でrpmファイルをダウンロードして、それを本番環境にインストールします。
まず、検証環境で以下のコマンドを叩いて、rpmファイルたちを .tar.gz にまとめます。
```bash
~]# mkdir mod_security
~]# yum install --downloadonly --downloaddir=./mod_security mod_security mod_security_crs
~]# tar zcvf mod_security.tar.gz ./mod_security
```
次に、tar.gzファイルをscpで検証環境から本番環境にコピーします。
```bash
$ scp root@検証サーバIP:/root/mod_security.tar.gz ./

$ scp mod_security.tar.gz root@本番サーバIP:~
```
コピーしたら、本番環境でrpmファイルをローカルインストールします。
```bash
~]# tar zxvf mod_security.tar.gz
~]# yum localinstall ./mod_security/*.rpm
```

### ApacheでModSecurityを有効化する
mod_securityをインストールすると /etc/httpd (Apache用) や /usr/lib (Nginx用) に必要なファイルが配置されます。

ApacheでModSecurityを有効化する設定ファイルは /etc/httpd/conf.d/mod_security.conf にあります。
この設定ファイルの SecRuleEngine が On だと有効化され、Off だと無効化されます。
```bash
~]# cat /etc/httpd/conf.d/mod_security.conf
<IfModule mod_security2.c>
    # ModSecurity Core Rules Set configuration
        IncludeOptional modsecurity.d/*.conf
        IncludeOptional modsecurity.d/activated_rules/*.conf

    # Default recommended configuration
    SecRuleEngine On
    SecRequestBodyAccess On
    SecRule REQUEST_HEADERS:Content-Type "text/xml" \
         "id:'200000',phase:1,t:none,t:lowercase,pass,nolog,ctl:requestBodyProcessor=XML"
    SecRequestBodyLimit 13107200
    SecRequestBodyNoFilesLimit 131072
    SecRequestBodyInMemoryLimit 131072
    ...
</IfModule>
```
また、ModSecurityのモジュールをロードしている設定ファイルは /etc/httpd/conf.modules.d/10-mod_security.conf にあります。
```bash
~]# cat /etc/httpd/conf.modules.d/10-mod_security.conf
LoadModule security2_module modules/mod_security2.so

<IfModule !mod_unique_id.c>
    LoadModule unique_id_module modules/mod_unique_id.so
</IfModule>
```
設定変更後に、モジュールが読み込まれることを確認して、httpdを再起動します。
```bash
~]# httpd -M | grep security
 security2_module (shared)

~]# systemctl restart httpd
```

### WAF動作検証

検証のためにPHPをインストールして、パラメータをそのまま表示するphpを用意します。
```bash
~]# yum install php
~]# systemctl restart httpd
~]# cat /var/www/html/index.php
<?php echo($_REQUEST['cmd']); ?>
```
POSTリクエストで「'」を含めたSQLiを試みるリクエストは403で拒否されます。
```bash
~]# curl -X POST "localhost/index.php" -d "cmd=123"
123

~]# curl -X POST "localhost/index.php" -d "cmd=123'"
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>403 Forbidden</title>
```
POSTリクエストで「`sleep(1)`」を含めた時間に基づくブラインドアタックを試みるリクエストも403で拒否されます。
```bash
~]# curl -X POST "localhost/index.php" -d "cmd=sleep"
sleep

~]# curl -X POST "localhost/index.php" -d "cmd=sleep(1)"
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>403 Forbidden</title>
```
POSTリクエストで「`<script>`」を含めたXSSを試みるリクエストも403で拒否されます。
```bash
~]# curl "localhost:80/index.php?cmd=script"
script

~]# curl -X POST "localhost/index.php" -d "cmd=<script>"
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>403 Forbidden</title>
```
POSTリクエストで「curl」や「wget」などのファイル取得コマンドを含む場合も403で拒否されます。
```bash
~]# curl -X POST "localhost/index.php" -d "cmd=google.com"
google.com

~]# curl -X POST "localhost/index.php" -d "cmd=curl%20google.com"
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>403 Forbidden</title>
```

mod_securityでアクセス拒否した場合は /var/log/httpd/modsec_audit.log に拒否ログが残ります。

以上です。

