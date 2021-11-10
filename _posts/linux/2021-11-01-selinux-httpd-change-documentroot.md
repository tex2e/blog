---
layout:        post
title:         "SELinuxでApacheで/var/wwwから変更した先のパスも許可する"
menutitle:     "SELinuxでApacheで/var/wwwから変更した先のパスも許可する (semanage fcontext -e)"
date:          2021-11-01
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

httpd でドキュメントルートを変更した際に SELinux の semanage fcontext の許可ルールを修正する方法について説明します。

httpd は通常SELinuxの httpd_t タイプにラベル付けされていて、/var/www/ は httpd_sys_*_t タイプにラベル付けされているので、httpd は /var/www/ にアクセスすることができます。
しかし、Apacheなどの設定ファイルでドキュメントルートを変更すると、SELinuxポリシーから外れてしまうため、httpd がアクセスできなくなります。

今回は Apache のドキュメントルートを /var/www から /var/test_www に変更する手順について説明します。
まずは httpd.conf の中に書かれているパス /var/www/html をすべて /var/test_www/html に書き換えます。

/etc/httpd/conf/httpd.conf 
```
#DocumentRoot "/var/www/html"
DocumentRoot "/var/test_www/html"
```
次に、ディレクトリ /var/test_www/ のSELinuxコンテキストを /var/www/ と比較します。
```bash
~]# ls -dZ /var/www/
system_u:object_r:httpd_sys_content_t:s0 /var/www/

~]# ls -dZ /var/test_www/
unconfined_u:object_r:var_t:s0 /var/test_www/
```
SELinuxコンテキストが異なるので、chcon などで /var/test_www/ のタイプを httpd_sys_content_t に変更したくなるのですが、/var/www のSELinuxコンテキストは複雑で、下のフォルダに行くと別のタイプが割り当てられている場合があります。
```bash
~]# semanage fcontext -l | grep ^/var/www
/var/www(/.*)?                       all files        system_u:object_r:httpd_sys_content_t:s0
/var/www(/.*)?/logs(/.*)?            all files        system_u:object_r:httpd_log_t:s0
/var/www/[^/]*/cgi-bin(/.*)?         all files        system_u:object_r:httpd_sys_script_exec_t:s0
/var/www/apcupsd/multimon\.cgi       regular file     system_u:object_r:apcupsd_cgi_script_exec_t:s0
...省略...
```
なので、以下のchconやsemanage fcontextでトップのディレクトリのタイプを変えるだけでは、後々別の部分でアクセス拒否される問題が発生する可能性があります。
```bash
~]# chcon -R -t httpd_sys_content_t /var/test_www                       # 一時的な解決策(非推奨)
~]# semanage fcontext -a -t httpd_sys_content_t "/var/test_www(/.*)?"   # 一時的な解決策(非推奨)
```
解決策として、semanage fcontext の -e オプション (Equal) を使って /var/test_www と /var/www のSELinuxコンテキストは同じであるというルールを定義します。
```bash
~]# semanage fcontext -a -e /var/www /var/test_www
~]# semanage fcontext -l
...省略...
SELinux Local fcontext Equivalence

/var/test_www = /var/www
```
ルール（ポリシー）を定義しただけでは反映されないので、restoreconコマンドで設定を反映させます。
反映させることで var_t タイプが httpd_sys_content_t タイプに付け変わります。
```bash
~]# restorecon -R -v /var/test_www
Relabeled /var/test_www from unconfined_u:object_r:var_t:s0 to unconfined_u:object_r:httpd_sys_content_t:s0
Relabeled /var/test_www/html from unconfined_u:object_r:var_t:s0 to unconfined_u:object_r:httpd_sys_content_t:s0
Relabeled /var/test_www/html/index.html from unconfined_u:object_r:var_t:s0 to unconfined_u:object_r:httpd_sys_content_t:s0
```
/var/test_www と /var/www が同じであると定義することで、簡単にルールを追加することができました。

検証が完了したので、最後に、先ほど定義したルールが不要という場合は、以下のコマンドで削除します。
削除後も restorecon でコンテキストを反映させる（元に戻す）のを忘れないようにしてください。
```bash
~]# semanage fcontext -d -e /var/www /var/test_www
~]# restorecon -R -v /var/test_www
```
以上です。
