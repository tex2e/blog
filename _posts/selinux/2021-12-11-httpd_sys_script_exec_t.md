---
layout:        post
title:         "SELinux上でhttpdがファイルを実行可能にする"
menutitle:     "SELinux上でhttpdがファイルを実行可能にする (httpd_sys_script_exec_t)"
date:          2021-12-11
category:      SELinux
cover:         /assets/cover6.jpg
redirect_from: /linux/httpd_sys_script_exec_t
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Apache(httpd)がファイル実行できるようにするには、対象の実行ファイルのSELinuxコンテキストを「httpd_sys_script_exec_t」にラベルを付け替えることで、httpdから実行できるようになります。

```bash
~]# chcon -t httpd_sys_script_exec_t /var/www/html/hello.sh
```

### 動作検証

まず、PHPファイルを用意し、内部のプログラムでファイルを実行するようにします。
```bash
~]# cat /var/www/html/hello.php
<?php
system("./hello.sh");
```

次に、bashで動作する実行ファイルを用意します。実行権限が付与されていることも確認します。
```bash
~]# cat /var/www/html/hello.sh
#!/bin/bash
echo hello

~]# chmod +x /var/www/html/hello.sh
~]# ls -l
-rw-r--r--. 1 root root 29 Nov 29 12:00 hello.php
-rwxr-xr-x. 1 root root 23 Nov 29 12:00 hello.sh
```

SELinuxが有効な状態では、対象のPHPにアクセスしても何も表示されません。
```bash
~]# curl localhost/hello.php
~]#
```

Apacheのエラーログを確認すると、権限がないことが原因で実行エラーが発生しています。
```bash
~]# tail -f /var/log/httpd/error_log
sh: ./hello.sh: Permission denied
```
監査ログを見ても、SELinuxのアクセス拒否は発生していないです（実際はdontauditルールによって表示されていないだけ）。
```bash
~]# tail -f /var/log/audit/audit.log | grep denied

```
デバッグのために、SELinuxのdontauditルールを無効にして全て監査ログに出力されるようにします。
```bash
~]# semodule -DB
```
再度curlでアクセスすると、監査ログに httpd が hello.sh の実行を拒否したログが記録されるようになりました。
```bash
~]# tail -f /var/log/audit/audit.log | grep denied
type=AVC msg=audit(0000000000.667:885): avc:  denied  { execute } for  pid=23823 comm="sh" name="hello.sh" dev="dm-0" ino=17350933 scontext=system_u:system_r:httpd_t:s0 tcontext=unconfined_u:object_r:httpd_sys_content_t:s0 tclass=file permissive=0
type=AVC msg=audit(0000000000.667:886): avc:  denied  { execute } for  pid=23823 comm="sh" name="hello.sh" dev="dm-0" ino=17350933 scontext=system_u:system_r:httpd_t:s0 tcontext=unconfined_u:object_r:httpd_sys_content_t:s0 tclass=file permissive=0
```
inoから実行(execute)しようとして対象ファイル(name="hello.sh", tclass="file")の場所を find コマンドで探します。
```bash
~]# find / -inum 17350933
/var/www/html/hello.sh
```
対象の実行ファイルをhttpdが実行できるように、「httpd_sys_script_exec_t」にラベルを付け替えます。
```bash
~]# chcon -t httpd_sys_script_exec_t /var/www/html/hello.sh
```
再度、curlでPHPにアクセスすると、bashを実行した結果が返ってきましたので、設定完了です。
```bash
~]# curl localhost/hello.php
hello
```
最後に、デバッグを終了するために、SELinuxのdontauditルールを有効にして必要最低限の監査ログだけを出力するようにします。
```bash
~]# semodule -B
```

今回は、httpdが実行するファイルのラベルを「httpd_sys_script_exec_t」に付け替えて対応しましたが、本来であれば、以下のフォルダにスクリプトを配置すれば、自動的に「httpd_sys_script_exec_t」タイプが割り当てられます。
httpd が実行するスクリプトは cgi-bin/ にまとめて置いておくのが、良いと思います。

```bash
~]# semanage fcontext -l | grep httpd_sys_script_exec_t
/usr/.*\.cgi                                regular file    system_u:object_r:httpd_sys_script_exec_t:s0
/opt/.*\.cgi                                regular file    system_u:object_r:httpd_sys_script_exec_t:s0
/var/www/[^/]*/cgi-bin(/.*)?                all files       system_u:object_r:httpd_sys_script_exec_t:s0
/var/www/perl(/.*)?                         all files       system_u:object_r:httpd_sys_script_exec_t:s0
/var/www/html/[^/]*/cgi-bin(/.*)?           all files       system_u:object_r:httpd_sys_script_exec_t:s0
/usr/lib/cgi-bin(/.*)?                      all files       system_u:object_r:httpd_sys_script_exec_t:s0
/var/www/cgi-bin(/.*)?                      all files       system_u:object_r:httpd_sys_script_exec_t:s0
/var/www/svn/hooks(/.*)?                    all files       system_u:object_r:httpd_sys_script_exec_t:s0
/usr/share/wordpress/.*\.php                regular file    system_u:object_r:httpd_sys_script_exec_t:s0
/usr/local/nagios/sbin(/.*)?                all files       system_u:object_r:httpd_sys_script_exec_t:s0
/usr/share/wordpress/wp-includes/.*\.php    regular file    system_u:object_r:httpd_sys_script_exec_t:s0
/usr/share/wordpress-mu/wp-config\.php      regular file    system_u:object_r:httpd_sys_script_exec_t:s0
```

以上です。

#### 補足

httpd関連のSELinuxコンテキストで重要なラベルは以下の3つです。
- httpd_sys_content_t : 読み取りのみ
- httpd_sys_script_exec_t : 実行可能
- httpd_sys_rw_content_t : 読み書き可能

