---
layout:        post
title:         "SELinux上でhttpdがファイル書き込み可能にする"
menutitle:     "SELinux上でhttpdがファイル書き込み可能にする (httpd_sys_rw_content_t)"
date:          2021-12-10
category:      Linux
cover:         /assets/cover6.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

Apache(httpd)がファイル書き込みできるようにするには、対象のファイルやディレクトリのSELinuxコンテキストを「httpd_sys_rw_content_t」にラベルを付け替えることで、httpdから書き込みができるようになります。

```bash
~]# chcon -t httpd_sys_rw_content_t /var/www/html/upload
```

### 動作検証

uploadディレクトリの権限を誰でも書き込み可能にします。
```bash
~]# chmod o+w /var/www/html/upload
~]# ls -ld /var/www/html/upload
drwxr-xrwx. 2 root root 6 Nov 28 12:00 /var/www/html/upload
```
ディレクトリuploadにファイルを作成するphpを配置します（本来はファイルアップロードのPHPを作成すべきですが、ファイル書き込みの検証だけなので、PHPのtouch関数を使っています）。
```bash
~]# cat /var/www/html/upload.php
<?php
$file_name = 'upload/file.txt';
if(!file_exists($file_name)){
  touch( $file_name );
}
```
phpのページにアクセスして、ファイルが作成されるか確認します。
```bash
~]$ curl localhost/upload.php
```
上のコマンドを実行すると、監査ログにエラーが出力され、ファイル書き込みがSELinuxによって拒否されたことが確認できます。
```bash
~]# tail -f /var/log/audit/audit.log | grep denied
type=AVC msg=audit(0000000000.958:282): avc:  denied  { write } for  pid=1647 comm="httpd" name="upload" dev="dm-0" ino=33584792 scontext=system_u:system_r:httpd_t:s0 tcontext=unconfined_u:object_r:httpd_sys_content_t:s0 tclass=dir permissive=0
```
httpdコマンド (comm="httpd") がuploadディレクトリ (name="upload", tclass=dir) に書き込み (write) をしたのでSELinuxに拒否されました。
SELinuxコンテキストは呼び出し元が「httpd_t」ドメインで、操作対象が「httpd_sys_content_t」タイプですが、この許可ルールは存在しないため、アクセス拒否されました。
書き込み先ディレクトリの場所は inode の番号から調べることができます。
```bash
~]# find / -inum 33584792
/var/www/html/upload
```
/var/www/html/uploadのコンテキストをhttpdが書き込み可能な「httpd_sys_rw_content_t」タイプに chcon コマンドで修正すると、httpdは対象ディレクトリにファイルを作成できるようになります。
```bash
~]# chcon -t httpd_sys_rw_content_t /var/www/html/upload

~]# curl localhost/upload.php
~]# ls /var/www/html/upload
file.txt
```
最後に、restoreconでコンテキストが元に戻らないように、永続的に設定しておきます。
```bash
~]# semanage fcontext -a -t httpd_sys_rw_content_t /var/www/html/upload
~]# semanage fcontext -l | grep /var/www/html/
/var/www/html/upload     all files     system_u:object_r:httpd_sys_rw_content_t:s0
```
restoreconコマンドでSELinuxコンテキストをデフォルトに戻しても、uploadディレクトリの「httpd_sys_rw_content_t」がタイプが維持されることを確認します。
```bash
~]# restorecon -v /var/www/html/upload
~]# ls -ldZ /var/www/html/upload
drwxr-xrwx. root root unconfined_u:object_r:httpd_sys_rw_content_t:s0 /var/www/html/upload
```
以上で設定は完了です。

#### 補足

httpd関連のSELinuxコンテキストで重要なラベルは以下の3つです。
- httpd_sys_content_t : 読み取りのみ
- httpd_sys_script_exec_t : 実行可能
- httpd_sys_rw_content_t : 読み書き可能
