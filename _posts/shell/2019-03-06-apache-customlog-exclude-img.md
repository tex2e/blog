---
layout:        post
title:         "Apache で画像やJSやフォントなどのログを除外する"
menutitle:     "Apache で画像やJSやフォントなどのログを除外する"
date:          2019-03-06
tags:          Shell
category:      Shell
author:        tex2e
cover:         /assets/cover8.jpg
redirect_from:
comments:      true
published:     true
---

Apache で画像やJavaScript、フォントなどのログを access_log から除外する方法について。
セキュリティの分野ではログを読む技術が重要視されますが、ログの大半が画像やフォントなどへのアクセスログだと萎えるので、問題を早く見つけるという意味でもログのフィルタやログの内容による分割は重要です。

CentOS なら /etc/httpd/conf/httpd.conf に設定ファイルがあります。
除外する設定は次のように書きます。
要求されたURIが下の正規表現にマッチするときは環境変数 nolog を設定し、CustomLog で nolog 以外のログを書き込むようにします。

```httpdconf
SetEnvIf Request_URI "\.(bmp|css|gif|htc|ico|jpe?g|js|mpe?g|png|swf|woff|ttf)$" nolog
CustomLog "logs/access_log" combined env=!nolog
```

また、画像などのログを完全に消す代わりに、別のログファイルに書き込みたい場合は、次のようにします。
下は nolog 以外のときは access_log に書き込み、nolog のときは img_access_log に書き込む例です。

```httpdconf
SetEnvIf Request_URI "\.(bmp|css|gif|htc|ico|jpe?g|js|mpe?g|png|swf|woff|ttf)$" nolog
CustomLog "logs/access_log" combined env=!nolog
CustomLog "logs/img_access_log" combined env=nolog
```

実際には、これらの設定は Apache の log_config_module の中で定義します。

```diff
# cd /etc/httpd/conf
# diff -u httpd.conf.bak httpd.conf
--- httpd.conf.bak
+++ httpd.conf
@@ -189,6 +189,9 @@
 LogLevel warn

 <IfModule log_config_module>
+    SetEnvIf Request_URI "\.(bmp|css|gif|htc|ico|jpe?g|js|mpe?g|png|swf|woff|ttf)$" nolog
+
     #
     # The following directives define some format nicknames for use with
     # a CustomLog directive (see below).
@@ -214,7 +217,8 @@
     # If you prefer a logfile with access, agent, and referer information
     # (Combined Logfile Format) you can use the following directive.
     #
-    CustomLog "logs/access_log" combined
+    CustomLog "logs/access_log" combined env=!nolog
 </IfModule>

 <IfModule alias_module>
```

詳しい設定については Apache 公式の [mod_log_config](http://httpd.apache.org/docs/current/mod/mod_log_config.html) に書かれています。
最後に httpd.conf を書き換えたら必ず httpd の再起動をします。

```
systemctl restart httpd
```


### (余談) ログファイル名とログローテーション

httpd で別のログファイルに書き込みたいときに自分でファイル名を決めると思いますが、ログファイルの名前が必ず「〜log」となるようにすると良いです。
なぜかというと、ログローテーションの設定ファイルが /etc/logrotate.d/httpd にあるのですが、それを見ると「〜log」というファイル名に対してログローテーションしているからです。

```
/var/log/httpd/*log {
  ...ログローテーションに関する設定...
}
```

つまり、ファイル名を「〜log」にしておくと勝手にログローテーションを実行してくれます。


### 参考文献

- [mod_log_config -- Apache HTTP Server Version 2.4](http://httpd.apache.org/docs/current/mod/mod_log_config.html)
