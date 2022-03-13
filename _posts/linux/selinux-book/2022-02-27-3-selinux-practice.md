---
layout:        book
title:         "3. SELinux/SELinuxの実践"
date:          2022-02-27
category:      Linux
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    true
# sitemap:       true
# feed:          true
description:   "SELinux入門 第3章 SELinuxの実践"
---


### SELinuxを有効化する

SELinuxはOSセットアップ時にデフォルトで有効化されていますが、システム管理者によって意図的に無効化されている場合があります。
ここでは、SELinuxを有効化する方法について説明します。
SELinuxが有効化されるためには、以下の条件を満たすこと必要があります。

1. ブートローダーの変数 kernelopts で、selinux=0 や enforcing=0 の設定が存在しないこと
2. 設定ファイル /etc/selinux/config で、SELINUX=enforcing または SELINUX=permissive の設定が存在すること

#### ブートローダーの設定ファイル

まず、ブートローダーの設定でSELinuxが有効になるかを確認するために、/boot/grub2/grubenv の内容を確認します。
以下のコマンドを実行して、出力が表示された場合、ブートローダーの設定でSELinuxが無効化されていることがわかります。

```bash
~]# grep -E 'kernelopts=(\S+\s+)*(selinux=0|enforcing=0)+\b' /boot/grub2/grubenv
```

上記コマンドで出力があり、ブートローダーの設定でSELinuxを有効化したい場合は、/etc/default/grub ファイルの変数 `GRUB_CMDLINE_LINUX_DEFAULT` や `GRUB_CMDLINE_LINUX` から `selinux=0` と `enforcing=0` の文字列を削除した後、以下のコマンドを実行して、ブートローダーの設定ファイルを生成します。

```bash
~]# grub2-mkconfig -o /boot/grub2/grub.cfg
```

設定が /boot/grub2/grubenv に反映されたら、システムを再起動します。

#### SELinuxの設定ファイル

ブートローダーで無効化されていなくても、SELinuxの設定ファイルで無効化されている場合は、SELinuxは有効化しません。
Disabledモード（無効化モード）から、Enforcingモード (強制モード) にするには /etc/selinux/config ファイルを修正し、`SELINUX=enforcing` に変更してから再起動する必要があります。
もし、対象のLinux環境で何が動作しているか詳しくなくて、Enforcingモードにすると主要なサービスが止まってしまう可能性がある場合は、`SELINUX=permissive` を指定して問題がないことを確認してから Enforcing モードにするという方法もあります。
ここでは、disabled を enforcing に変更して再起動するという方法を行います。

/etc/selinux/config

```conf
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=enforcing
# SELINUXTYPE= can take one of these three values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected.
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted
```

設定ファイルを修正したら、サーバを再起動します。

```bash
~]# reboot
```

DisableからPermissiveまたはEnforcingモードにする際は、再ラベル付け (Relabeling) が発生するので、再起動が完了するまでに非常に時間がかかります。

再起動時のSELinuxを有効化中のログ：

```
selinux-autorelabel[796]: *** Warning -- SELinux targeted policy relabel is required.
selinux-autorelabel[796]: *** Relabeling could take a very long time, depending on file system size and speed of hard drivers
```

再起動が完了したら、getenforce コマンドを実行して、現在のSELinuxの動作モードを確認します。
Disabled 以外が出力されたら、SELinuxが有効化されていることが確認できます。

```bash
~]# getenforce
Enforcing
```

なお、setenforce コマンドは Permissive モードと Enforcing モードの切り替えコマンドなので、Disabledモードのときは使用できませんが、SELinuxが有効化されると setenforce コマンドが使用できるようになります。

```bash
~]# setenforce 0
~]# getenforce
Permissive
~]# setenforce 1
~]# getenforce
Enforcing
```



### httpdにファイル書き込みを許可する

結論だけ言うと、対象ディレクトリのタイプを「httpd_sys_rw_content_t」に変更することで、httpd_t ドメインは対象ディレクトリにファイル書き込み可能になります。

一般的に、Apache や Nginx などのプロセスは httpd_t ドメインで動作します。
そして、httpd から呼び出されてサーバー上で実行する PHP なども httpd_t ドメインで動作します。
ただし、httpd_t ドメインで動作することによって、ファイル書き込みなどの処理が制限される場合があります。

例えば、PHPがアップロードディレクトリにファイル書き込み可能にするには、LinuxのDACの設定と、SELinuxのMACの設定の両方が必要です。
DACの設定では、対象ディレクトリの所有者を apache や nginx ユーザに変更するか、所有者は root ユーザで権限を 777 にするなどの対応をすることで、httpdから対象ディレクトリへの書き込みを許可します。

```bash
~]# chown apache:apache /var/www/html/upload
# または
~]# chmod o+w /var/www/html/upload
```

一方、MACの設定では、対象ディレクトリのタイプの割り当てが適切かどうか確認し、ポリシーと一致しない場合はラベル付けの修正やポリシールールの追加などを行います。
httpd の場合、主によく使われるタイプとして以下の3つのタイプが存在します。

- httpd_sys_content_t : 読み取りのみ (デフォルト)
- httpd_sys_rw_content_t : 読み書き可能
- httpd_sys_script_exec_t : 実行可能

今回のアップロードディレクトリの場合は、対象ディレクトリのタイプを読み書き可能の「httpd_sys_rw_content_t」に付け替えることで、httpdからの書き込みを許可します。

```bash
chcon -t httpd_sys_rw_content_t /var/www/html/upload
```

以下では、PHP が /var/www/html/upload ディレクトリに書き込みできるようにするまでの手順を説明します。
まず、uploadディレクトリの権限を誰でも書き込み可能にします。

```bash
~]# chmod o+w /var/www/html/upload
~]# ls -ld /var/www/html/upload
drwxr-xrwx. 2 root root 6 Nov 28 12:00 /var/www/html/upload
```

次に、ディレクトリuploadにファイルを作成するPHPを配置します。本来はファイルアップロード画面のPHPを作成すべきですが、ファイル書き込みの検証だけなので、PHPのtouch関数を使っています。

/var/www/html/upload.php
```php
<?php
$file_name = 'upload/file.txt';
touch($file_name);
```
SELinuxのラベル付けを修正する前にPHPのページにアクセスして、ファイルが作成されるか確認します。

```bash
~]# curl localhost/upload.php
```

上記のコマンドを実行すると、監査ログにエラーが出力され、ファイル書き込みがSELinuxによって拒否されました。

```
tail -f /var/log/audit/audit.log | grep denied
type=AVC msg=audit(0000000000.958:282): avc:  denied  { write } for  pid=1647 comm="httpd" name="upload" dev="dm-0" ino=33584792 scontext=system_u:system_r:httpd_t:s0 tcontext=unconfined_u:object_r:httpd_sys_content_t:s0 tclass=dir permissive=0
```

httpdコマンド (comm="httpd") がuploadディレクトリ (name="upload", tclass=dir) に書き込み (write) をしたのでSELinuxに拒否されたことがログから確認できます。
セキュリティコンテキストは呼び出し元が「httpd_t」ドメインで、操作対象が「httpd_sys_content_t」タイプでしたが、この許可ルールは存在しないため、アクセス拒否されました。
書き込み先ディレクトリの場所は inode の番号から調べることができます。

```bash
~]# find / -inum 33584792
/var/www/html/upload
```

/var/www/html/uploadのコンテキストを、httpd読み取り専用の「httpd_sys_content_t」から、httpdが書き込み可能な「httpd_sys_rw_content_t」タイプに chcon コマンドで修正すると、httpdは対象ディレクトリにファイルを作成できるようになります。

```bash
~]# chcon -t httpd_sys_rw_content_t /var/www/html/upload

~]# curl localhost/upload.php
~]# ls /var/www/html/upload
file.txt
```

最後に、restoreconでセキュリティコンテキストが元に戻らないように、semanage fcontext で永続的に設定しておきます。

```bash
~]# semanage fcontext -a -t httpd_sys_rw_content_t /var/www/html/upload
~]# semanage fcontext -l | grep /var/www/html/upload
/var/www/html/upload     all files     system_u:object_r:httpd_sys_rw_content_t:s0
```

restoreconコマンドでセキュリティコンテキストをデフォルトに戻しても、uploadディレクトリのタイプ「httpd_sys_rw_content_t」が維持されることを確認します。

```bash
~]# restorecon -v /var/www/html/upload
~]# ls -ldZ /var/www/html/upload
drwxr-xrwx. 2 root root unconfined_u:object_r:httpd_sys_rw_content_t:s0  /var/www/html/upload
```

以上で設定は完了です。
httpd_t ドメインが httpd_sys_rw_content_t タイプの /var/www/html/upload ディレクトリにファイル書き込みができるようになりました。



### httpdにCGIプログラム実行を許可する

結論だけ言うと、対象ファイルのタイプを「httpd_sys_script_exec_t」に変更することで、httpd_t ドメインは対象ファイルを実行することが可能になります。

例えば、Apache が CGI を動作させるためには、LinuxのDACの設定と、SELinuxのMACの設定の両方が必要です。
DACの設定では、対象のCGIファイルに実行権限を付与するように設定します。

```bash
~]# chmod +x hello.cgi
```

一方、MACの設定では、対象のCGIファイルのタイプを httpd が実行可能な「httpd_sys_script_exec_t」に付け替えることで、httpdからの実行を許可します。

```bash
~]# chcon -R -t httpd_sys_script_exec_t /var/www/cgi-bin
```

以下では、Apache が CGI を実行できるようにするまでの手順を説明します。
まず、Apacheの設定ファイル /etc/httpd/conf/httpd.conf を修正して CGI を有効化します。
以下のようにApacheの設定を確認して、実行ファイルを配置する場所を確認します。
ここでは /var/www/cgi-bin が配置先です。

```xml
<IfModule alias_module>
    ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"
</IfModule>

<Directory "/var/www/cgi-bin">
    AllowOverride None
    Options None
    Require all granted
</Directory>
```

/var/www/cgi-bin/hello.cgi
```bash
#!/bin/bash
echo "Content-Type: text/plain"
echo ""
echo "Hello, CGI world!"
```

この時点で、作成したファイルのタイプは「httpd_sys_script_exec_t」です。

```bash
~]# chmod +x /var/www/cgi-bin/hello.cgi
~]# ls -Z /var/www/cgi-bin/hello.cgi
unconfined_u:object_r:httpd_sys_script_exec_t:s0 /var/www/cgi-bin/hello.cgi
```

curlでWeb経由でアクセスしてみます。

```bash
~]# curl http://localhost/cgi-bin/hello.cgi
Hello, CGI world!
```

問題なくCGIが実行されることが確認できます。
続いて、cgi-bin ディレクトリ以外の場所にCGIファイルを配置できるように Apache の設定ファイルを修正します。
/var/www/html ディレクトリ全体でCGI実行できるように ExecCGI を追加し、拡張子が .cgi なら cgi-script として実行するための AddHandler を追加します。

/etc/httpd/conf/httpd.conf
```xml
<Directory "/var/www/html">
    Options Indexes FollowSymLinks ExecCGI
    ...
</Directory>

<IfModule mime_module>
    ...
    AddHandler cgi-script .cgi
    ...
</IfModule>
```

設定を修正したら、httpd を再起動します。

```bash
~]# systemctl restart httpd
```

先ほど cgi-bin に作成した hello.cgi を cgi-bin 以外のディレクトリにコピーします。
ファイルコピーしたとき、DACの権限は 755 のままでコピーされますが、セキュリティコンテキストはコピーされません。
```bash
~]# cp /var/www/cgi-bin/hello.cgi /var/www/html/hello.cgi
~]# ls -lZ /var/www/html/hello.cgi
-rwxr-xr-x. 1 root root unconfined_u:object_r:httpd_sys_content_t:s0   /var/www/html/hello.cgi
```

CGIファイルのタイプを「httpd_sys_content_t」のまま、Web経由でアクセスすると、500エラーになります。
```bash
~]# curl http://localhost/hello.cgi
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>500 Internal Server Error</title>
```

Apacheのエラーログは /var/log/httpd/error_log に記録されます。
確認すると、/var/www/html/hello.cgi に対する実行権限がないことが原因のようです。
```
[cgid:error] [pid 48240:tid 139958010439424] [client ::1:57314] AH01241: error spawning CGI child: exec of '/var/www/html/hello.cgi' failed (Permission denied): /var/www/html/hello.cgi
```

DACの権限は 755 で実行可能なので、SELinuxのMACで拒否されたと推測できます。
しかし、監査ログを確認しても、httpd に関する拒否ログは記録されませんでした。

```bash
~]# tail -f /var/log/audit/audit.log
```

SELinuxが拒否しても監査ログに記録されないのは、Dontauditルールが使われているためです。
sesearch コマンドを使ったポリシールールの検索で、`--dontaudit` を指定して、httpd_t ドメインの実行に関するDontauditルールを調べます。

```bash
~]# sesearch --dontaudit -s httpd_t -p execute
dontaudit httpd_t exec_type:file { execute execute_no_trans };
```

結果から、httpd_t ドメインが exec_type 属性のファイルを実行する場合、拒否しても監査ログに残さないことが確認できます。
また、exec_type 属性について調べると、末尾が `_exec_t` のタイプは exec_type 属性を持つことが、以下の seinfo の結果から確認できます。
つまり、httpd_t ドメインが httpd_*_exec_t タイプのファイルを実行する場合、拒否ログは記録されないことがわかります。

```bash
]# seinfo -a exec_type -x
Type Attributes: 1
   attribute exec_type;
        ...
        httpd_exec_t
        httpd_helper_exec_t
        httpd_initrc_exec_t
        httpd_passwd_exec_t
        httpd_php_exec_t
        httpd_rotatelogs_exec_t
        httpd_suexec_exec_t
        httpd_sys_content_t
        httpd_sys_script_exec_t
        httpd_unconfined_script_exec_t
        httpd_user_script_exec_t
        ...
```

SELinuxの拒否ログを監査ログに記録するには、semodule で -D (Disable dontaudit) を追加して -B (Build) でポリシーをビルドします。

```bash
~]# semodule -DB
```

ビルドした後に、同じようにWeb経由で対象のCGIにアクセスし、拒否ログが記録されるかを確認します。

```bash
~]# curl http://localhost/hello.cgi
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>500 Internal Server Error</title>
...

~]# tail -f /var/log/audit/audit.log | grep denied
```

ポリシーの Dontaudit ルールを無効化したので、今回は拒否ログが記録されます。
監査ログには以下の拒否ログが残っていました。
拒否ログの内容から、httpd_t ドメインが httpd_sys_content_t タイプのファイルの実行を試みたので拒否したことが確認できます。

```
type=AVC msg=audit(0000000000.916:7372): avc:  denied  { execute } for  pid=48590 comm="httpd" name="hello.cgi" dev="dm-0" ino=51024902 scontext=system_u:system_r:httpd_t:s0 tcontext=unconfined_u:object_r:httpd_sys_content_t:s0 tclass=file permissive=0
```

上記の拒否ログを audit2allow で解析すると、どのようなルールを追加すれば拒否されなくなるかがわかります。
結果から、httpd_unified という Boolean を on にするか「allow httpd_t httpd_sys_content_t:file execute」のルールを追加すれば良いことがわかります。

```bash
~]# echo '<上記の拒否ログ>' | audit2allow
#============= httpd_t ==============
#!!!! This avc can be allowed using the boolean 'httpd_unified'
allow httpd_t httpd_sys_content_t:file execute;
```

一方で、httpd_t ドメインがファイル実行を許可されているルールは、以下のように sesearch コマンドに、-s (Source) で呼び出し元のドメインで httpd_t、-c (object Class) でオブジェクトクラス file、-p (Permission) でファイルの実行権限 execute を指定して検索すると、実行したいファイルに付けるべき適切なタイプを知ることができます。
```bash
~]# sesearch -A -s httpd_t -c file -p execute
...
allow httpd_t httpd_sys_script_exec_t:file { execute execute_no_trans getattr ioctl map open read }; [ httpd_enable_cgi ]:True
...
```

この時点で、httpd_t ドメインがファイルを実行するには、以下の選択肢のいずれかで対応できるということが考えられます。

- 選択肢A : 許可ルールに合わせて、hello.cgi のタイプを httpd_sys_script_exec_t に付け替える (推奨)
- 選択肢B : 別の許可ルールを有効にするために、httpd_unified という Boolean を on にする
- 選択肢C : 別の許可ルールを新規追加するため、「allow httpd_t httpd_sys_content_t:file execute」のルールを含む自作ポリシーモジュールを作成する

今回は対象の1ファイルを httpd_t ドメインが実行できるようにするだけなので、選択肢Aのラベルの修正を行います。
chcon で一時的にラベルを httpd_sys_script_exec_t タイプに付け替えて、CGIが実行できることを確認します。

```bash
~]# chcon -t httpd_sys_script_exec_t /var/www/html/hello.cgi

~]# ls -lZ /var/www/html/hello.cgi
-rwxr-xr-x. 1 root root unconfined_u:object_r:httpd_sys_script_exec_t:s0   /var/www/html/hello.cgi

~]# curl http://localhost/hello.cgi
Hello, CGI world!
```

正常に動作することを確認したら、一時的に変えたファイルコンテキストのルールを永続化します。
また、無効化していた Dontaudit ルールも元に戻しておきます。

```bash
~]# semanage fcontext -a -t httpd_sys_script_exec_t /var/www/html/hello.cgi
~]# restorecon -v /var/www/html/hello.cgi

~]# semodule -B
```



### Pythonの簡易Webサーバを httpd_t ドメインで動作させる

python3 の http.server モジュールを使用した簡易Webサーバを httpd_t ドメインで起動させます。
手動で起動すると、unconfined_t ドメインで動作してしまうので、systemd経由でWebサーバが起動するようにします。
まず、以下の systemd のユニットファイルを作成します。
重要なポイントは、プロセス起動時のドメインを SELinuxContext で指定する部分です。
python のプロセスが、httpd_t ドメインで動作するように指定します。
```bash
cat <<'EOS' > /etc/systemd/system/simplehttpserver.service
[Unit]
Description=Python Simple HTTP Server
After=syslog.target network.target auditd.service

[Service]
ExecStart=/usr/bin/python3 -m http.server 8000
ExecStop=/bin/kill -HUP $MAINPID
WorkingDirectory=/var/www/html
SELinuxContext=system_u:system_r:httpd_t:s0

[Install]
WantedBy=multi-user.target
EOS
```

作成したファイルは、/etc/systemd/system 直下に配置します。
ここで、ファイルのタイプが systemd_unit_file_t であることを確認します。
```bash
~]# ls -Z /etc/systemd/system/simplehttpserver.service
unconfined_u:object_r:systemd_unit_file_t:s0 /etc/systemd/system/simplehttpserver.service
```

新規作成したサービスを起動してみます。daemon-reload した後に、start します。
正しく起動したか確認するために、status も実行します。
```bash
systemctl daemon-reload
systemctl start simplehttpserver
systemctl status simplehttpserver
```
この時点では、正常に起動できませんでした。
/var/log/messages を確認すると、pythonのプロセスが 203 で異常終了しています。
```
Feb 11 12:00:00 localhost.localdomain systemd[1]: Started Python Simple HTTP Server.
Feb 11 12:00:00 localhost.localdomain systemd[1]: simplehttpserver.service: Main process exited, code=exited, status=203/EXEC
Feb 11 12:00:00 localhost.localdomain systemd[1]: simplehttpserver.service: Failed with result 'exit-code'.
```
次に、監査ログの /var/log/audit/audit.log を確認すると、SELinuxによってPython関係のアクションが拒否されていました。
拒否ログの内容から、bin_t のファイルで (bin_t をエントリーポイントとして) httpd_t ドメインのプロセスを起動させる許可ルールがないために拒否されたことが確認できます。
```
type=AVC msg=audit(0000000000.719:695): avc:  denied  { entrypoint } for  pid=10457 comm="(python3)" path="/usr/libexec/platform-python3.6" dev="dm-0" ino=35081046 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:bin_t:s0 tclass=file permissive=0
```

この環境だと、/usr/bin/python3 の実態は /usr/libexec/platform-python3.6 ですが、このプログラムはデフォルトで bin_t タイプでラベル付けされているため、bin_t ファイルを使って httpd_t ドメインのプロセスを起動するドメイン遷移のルールに一致せず、アクションが拒否されました。
通常は、httpd_t ドメインのプロセスを起動するファイルには、httpd_exec_t タイプのラベル付けが必要です。
そのため、`chcon -t httpd_exec_t /usr/libexec/platform-python3.6` を実行して python3 プログラムのラベルを変えてもいいのですが、python3 を使用している他のプログラムに影響が出るかもしれないので、ここではファイルコンテキストの代わりにポリシールールを変更します。

まず、監査ログの /var/log/audit/audit.log に出力された拒否ログの行をそのまま audit2allow に渡して実行します。
audit2allow は入力を解析して、どのようなポリシールールを追加すれば拒否されなくなるかを教えてくれます。
実行すると以下のように出力され、httpd_tドメインがbin_tタイプのファイルをドメイン遷移のエントリーポイント (開始位置) として使用することを許可すればいいことがわかります。
```bash
~]# echo '<上記の拒否ログ>' | audit2allow

#============= httpd_t ==============
allow httpd_t bin_t:file entrypoint;
```

追加するポリシールールを確認したら、ポリシーパッケージを作成します。
作り方は、audit2allow のオプションに -M でモジュール名を指定して実行すると、.pp という拡張子のポリシーパッケージが作成されます。
それを SELinux のモジュールに追加するには semodule -i でモジュールをインストールします。
```bash
~]# echo '<上記の拒否ログ>' | audit2allow -M simplehttpserver

~]# semodule -i simplehttpserver.pp
```

bin_t ファイルで、httpd_t ドメインのプロセスが起動できるようになったので、再度自作サービスを起動します。
```bash
~]# systemctl start simplehttpserver
~]# systemctl status simplehttpserver
```
この時点でもまだ起動できませんでしたが、エラーの内容は変化しました。
/var/log/messages のログを確認すると、Pythonのプロセスがポートのバインドに失敗していることが確認できます。
```
Feb 11 12:01:00 localhost systemd[1]: Started Python Simple HTTP Server.
...
Feb 11 12:01:00 localhost python3[10666]:  File "/usr/lib64/python3.6/socketserver.py", line 470, in server_bind
Feb 11 12:01:00 localhost python3[10666]:    self.socket.bind(self.server_address)
Feb 11 12:01:00 localhost python3[10666]: PermissionError: [Errno 13] Permission denied
Feb 11 12:01:00 localhost systemd[1]: simplehttpserver.service: Main process exited, code=exited, status=1/FAILURE
Feb 11 12:01:00 localhost systemd[1]: simplehttpserver.service: Failed with result 'exit-code'.
```

再び監査ログの /var/log/audit/audit.log を確認すると、SELinuxによってポートのバインドが拒否されていました。
許可するためには、httpd_t が soundd_port_t (8000番ポート) に name_bind (ポートのバインド) をするポリシールールを追加すれば良さそうです。
```
type=AVC msg=audit(0000000000.702:709): avc:  denied  { name_bind } for  pid=10666 comm="python3" src=8000 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:soundd_port_t:s0 tclass=tcp_socket permissive=0
```
audit2allow + semodule でポリシールールを追加する方法もありますが、ポートのルールは専用のコマンドである `semanage port` を使えばポートのアクセス制御を管理することができます。
まず、拒否ログの soundd_port_t が何番ポートを表すのかを、-l (リスト) オプションで確認します。以下の結果から、soundd_port_t は 8000/tcp であることが確認できます。
```bash
~]# semanage port -l | grep soundd_port_t
soundd_port_t                  tcp      8000, 9433, 16001
```

httpd_t が 8000 番ポートでサービスを待ち受けできるように、http_port_t に 8000/tcp を追加します。
```bash
~]# semanage port -a -t http_port_t -p tcp 8000
~]# semanage port -l | grep http_port_t
```

ただし、オプション -a (追加) で実行すると「ValueError: Port tcp/8000 already defined」のようなエラーが発生する場合があります。そのときは -m (修正) に変えてからポートを許可します。
今回は、8000番ポートは既に soundd_port_t に割り当てられているため、-m (修正) で追加する必要があります。
```bash
~]# semanage port -m -t http_port_t -p tcp 8000
~]# semanage port -l | grep http_port_t
http_port_t                    tcp      8000, 80, 81, 443, 488, 8008, 8009, 8443, 9000
```

httpd_t が 8000 番ポートでサービスを待ち受けできるようにしたら、再度自作サービスを起動します。
```bash
~]# systemctl start simplehttpserver
~]# systemctl status simplehttpserver

* simplehttpserver.service - Python Simple HTTP Server
   Loaded: loaded (/etc/systemd/system/simplehttpserver.service; disabled; vendor preset: disabled)
   Active: active (running)
 Main PID: 10749 (python3)
    Tasks: 1 (limit: 11392)
   Memory: 9.2M
   CGroup: /system.slice/simplehttpserver.service
           `-10749 /usr/bin/python3 -m http.server 8000

Feb 15 23:48:15 localhost.localdomain systemd[1]: Started Python Simple HTTP Server.
```

今度は問題なくサービスが起動しました。
動作確認のために、適当な index.html を /var/www/html に配置して、curl経由でアクセスします。
ファイルの中身の文字列が返ってきたら正常に稼働しています。
```bash
~]# cat /var/www/html/index.html
hello world!
~]# curl localhost:8000
hello world!
```

8000番ポートで待ち受けているサービスが、確かに自作サービスのPythonで、httpd_t ドメインで動作していることを確認します。
管理者権限で実行する ss -talpn に -Z オプションを追加するだけで、プロセスのドメインも表示されます。
以下の例では問題なく自作サービスが 8000 番ポートで httpd_t ドメインで動いていることが確認できます。
```bash
~]# ss -talpnZ
State    Recv-Q   Send-Q   Local Address:Port   Peer Address:Port   Process
LISTEN   0        5              0.0.0.0:8000        0.0.0.0:*      users:(("python3",pid=11872,proc_ctx=system_u:system_r:httpd_t:s0,fd=5))
```

自作サービスは httpd_t ドメインで動いているので、httpd_sys_*_t タイプのファイルにアクセスできますが、それ以外のタイプにはアクセスできません。
試しに、user_home_t タイプのラベルを持つファイル test.html を作成して、httpd_t からアクセスできないことを確認してみます。
```bash
~]# ls -Z /var/www/html/test.html
unconfined_u:object_r:user_home_t:s0 /var/www/html/test.html

~]# curl localhost:8000/test.html
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
        "http://www.w3.org/TR/html4/strict.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html;charset=utf-8">
        <title>Error response</title>
    </head>
    <body>
        <h1>Error response</h1>
        <p>Error code: 404</p>
        <p>Message: File not found.</p>
        <p>Error code explanation: HTTPStatus.NOT_FOUND - Nothing matches the given URI.</p>
    </body>
</html>
```
httpd_t ドメインから user_home_t タイプのファイルにアクセスしようとすると、404になりました。
監査ログの /var/log/audit/audit.log を確認すると、httpd_t プロセスの user_home_t への読み取りを拒否したログが記録されていました。
```
type=AVC msg=audit(0000000000.311:753): avc:  denied  { read } for  pid=10749 comm="python3" name="test.html" dev="dm-0" ino=17856687 scontext=system_u:system_r:httpd_t:s0 tcontext=unconfined_u:object_r:user_home_t:s0 tclass=file permissive=0
```
以上で、自作サービスのPython3の簡易Webサーバを、httpd_t ドメインとして起動させて、アクセス制御できるようにしました。

しかし、Python3.6の本体のファイルである /usr/libexec/platform-python3.6 を bin_t から httpd_exec_t にラベル変更すると、別のシステムのプログラムで問題が発生しました。
監査ログに記録された拒否ログは、以下のようなものでした。
幸い、システムが停止するほどの深刻なものではないですが、システムが使用しているプログラムのラベルを安易に変えるのは危険です。

```
type=AVC msg=audit(0000000000.497:4836): avc:  denied  { execute } for  pid=12914 comm="dbus-daemon-lau" name="platform-python3.6" dev="dm-0" ino=35081046 scontext=system_u:system_r:system_dbusd_t:s0-s0:c0.c1023 tcontext=system_u:object_r:httpd_exec_t:s0 tclass=file permissive=0
```

そこで、python3.6の本体のファイルをコピーして、元々のPythonを bin_t、簡易Webサーバ用に使うPythonを httpd_exec_t にラベル付けします。

```bash
~]# cp /usr/libexec/platform-python3.6 /usr/libexec/platform-python3.6_simplehttpserver
~]# restorecon -v /usr/libexec/platform-python3.6
~]# chcon -t httpd_exec_t /usr/libexec/platform-python3.6_simplehttpserver
~]# ls -Z /usr/libexec/platform-python3.6*
           system_u:object_r:bin_t:s0 /usr/libexec/platform-python3.6
unconfined_u:object_r:httpd_exec_t:s0 /usr/libexec/platform-python3.6_simplehttpserver
```

ここで注意点ですが、lnでリンクを貼った場合は、セキュリティコンテキストが2つのファイル間で同じになってしまうため、別のラベルを付けたい場合は必ずコピーする必要があります。

python3.6の本体のファイルをコピーしたら、デーモンが呼び出すプログラムのパスを修正します。
/etc/systemd/system/simplehttpserver.service を以下のように修正します。

```diff
 [Unit]
 Description=Python Simple HTTP Server
 After=syslog.target network.target auditd.service

 [Service]
-ExecStart=/usr/bin/python3 -m http.server 8000
+ExecStart=/usr/libexec/platform-python3.6_simplehttpserver -m http.server 8000
 ExecStop=/bin/kill -HUP $MAINPID
 WorkingDirectory=/var/www/html
 SELinuxContext=system_u:system_r:httpd_t:s0

 [Install]
 WantedBy=multi-user.target
```
サービスファイルを修正して保存したらリロードして、サービスを再起動します。
```bash
systemctl daemon-reload
systemctl restart simplehttpserver
systemctl status simplehttpserver
```
問題なく動作することを確認したら、コピーしたプログラムのファイルコンテキストを設定し、永続的にラベル付けします。
```bash
~]# semanage fcontext -a -t httpd_exec_t '/usr/libexec/platform-python[0-9]+\.[0-9]+_simplehttpserver'
~]# restorecon -v /usr/libexec/platform-python*
```
以上で、Pythonプログラムの本体のラベルを変更せずに、自作サービスのPython3の簡易Webサーバを、httpd_t ドメインとして起動させて、アクセス制御できるようにしました。


### 既存の組み込みポリシーを修正する

SELinuxのポリシーは暗黙の拒否 (Default Deny) のため、allowルールを追加しないとドメインのプロセスは何も実行できません。
そのため、プロセスが期待通りに動作させるために、ポリシールールにallowルールを追加していく流れになります。
SELinuxの組み込みのポリシーは、システム管理者が全てのプログラムに対するラベル付けを意識しなくてもある程度ラベル付けをしてくれます。
しかし、場合によっては組み込みポリシーが必要以上に許可しすぎているときもあります。
denyルールを定義することはできないので、組み込みポリシーのルールを修正する必要があります。
そのためには、ポリシーファイルを編集して再ビルドする必要があります。
ここでは、ポリシーファイルを編集して、組み込みポリシーのモジュールを残したまま、同じ名前のカスタムモジュールを有効化し、組み込みポリシーのルールを修正する方法を紹介します。

まず、SELinuxポリシーのバージョンを確認します。

```bash
~]$ rpm -qi selinux-policy
Name        : selinux-policy
Version     : 3.14.3
Release     : 80.el8_5.2
Architecture: noarch
Install Date: Mon Feb 14 00:08:04 2022
Group       : Unspecified
Size        : 24923
License     : GPLv2+
Signature   : RSA/SHA256, Tue Dec 21 17:12:31 2021, Key ID 05b555b38483c65d
Source RPM  : selinux-policy-3.14.3-80.el8_5.2.src.rpm     <-- ここに注目
Build Date  : Tue Dec 21 15:21:09 2021
Build Host  : x86-01.mbox.centos.org
Relocations : (not relocatable)
Packager    : CentOS Buildsys <bugs@centos.org>
Vendor      : CentOS
URL         : https://github.com/fedora-selinux/selinux-policy
Summary     : SELinux policy configuration
Description :
SELinux Base package for SELinux Reference Policy - modular.
Based off of reference policy: Checked out revision  2.20091117
```

ソースコードを取得するために、https://rpmfind.net のページで「selinux-policy」を検索し、表示されたページ一覧の中から先ほど確認したバージョンと同じところにアクセスします。
ここでは、上記で確認したバージョンと同じ「selinux-policy-3.14.3-80.el8.noarch.html」の行で「x86_64」が含まれている行のリンクにアクセスします (rpmではなく、htmlへのリンクをクリックします)。
<!--
https://rpmfind.net/linux/RPM/centos/8-stream/baseos/x86_64/Packages/selinux-policy-3.14.3-80.el8.noarch.html
-->
続いて、ソースコードのRPMをダウンロードします。
表示されたページの「Source RPM: selinux-policy-3.14.3-80.el8.src.rpm」からリンクのURLをコピーして、コンソールからwgetでダウンロードします。

```bash
~]$ wget https://vault.centos.org/8-stream/BaseOS/Source/SPackages/selinux-policy-3.14.3-80.el8.src.rpm
```

ダウンロードが完了したら、取得したRPMをインストールします。
インストールと言ってもシステムに既に入っているものと同じバージョンのため、実際にインストール処理が走る訳ではないです。
インストールすると ~/rpmbuild/SPECS/selinux-policy.spec ファイルが作成されます。
```bash
~]# rpm -i selinux-policy-3.14.3-80.el8.src.rpm
```

次に、rpmbuildコマンドを使って、RPMパッケージからソースコードを抽出します。
rpmbuild コマンドは、rpm-build パッケージをインストールすることで使用できるようになります。
```bash
~]# dnf install rpm-build
```

rpmbuild コマンドの `-bp` (Build Prep) は、RPMパッケージからソースコードを抽出するためのオプションです。
-bp で実行時に、必要なパッケージがないと言われた場合は、追加で dnf install でインストールします。
```bash
~]# rpmbuild -bp /root/rpmbuild/SPECS/selinux-policy.spec
error: Failed build dependencies:
        gcc is needed by selinux-policy-3.14.3-80.el8.noarch
        m4 is needed by selinux-policy-3.14.3-80.el8.noarch
        policycoreutils-devel >= 2.9 is needed by selinux-policy-3.14.3-80.el8.noarch

~]# dnf install gcc m4 policycoreutils-devel

~]# rpmbuild -bp /root/rpmbuild/SPECS/selinux-policy.spec
...
+ exit 0
```

`-bp` で実行した結果、exit 0 で正常終了すると、RPMから抽出したソースコードは /root/rpmbuild/BUILD/selinux-policy-8f5*f66/ (後半の文字列はランダム) に出力されます。
ポリシーモジュールを作成するためのソースコードは ./policy/modules/contrib 内に存在します。

ここでは、既存の tomcat のポリシーを修正します。
tomcat の関連ファイルは ./policy/modules/contrib/ の直下に含まれています。

```bash
~]# cd /root/rpmbuild/BUILD/selinux-policy-8f5*f66/policy/modules/contrib/
~]# cp tomcat.te{,.bak}
```

tomcat.te ファイルには、tomcat が unreserved_port (未定義のポート) への接続を許可する corenet_tcp_connect_unreserved_ports マクロが書かれているので、これをコメントアウトして拒否するようにします。
ファイルの変更箇所は以下の通りです。

```bash
~]# diff -u tomcat.te.bak tomcat.te
```

tomcat.te
```diff
 corenet_tcp_connect_http_cache_port(tomcat_domain)
 corenet_tcp_connect_amqp_port(tomcat_domain)
 corenet_tcp_connect_ibm_dt_2_port(tomcat_domain)
-corenet_tcp_connect_unreserved_ports(tomcat_domain)
+#corenet_tcp_connect_unreserved_ports(tomcat_domain)
 corenet_tcp_bind_jboss_management_port(tomcat_domain)
 corenet_tcp_connect_smtp_port(tomcat_domain)
...
```

ポリシールールのファイルを編集したら、`make policy` で全てのポリシーモジュールパッケージを作成できますが、今回は tomcat.pp のみ作成したいので、`make tomcat.pp` コマンドを実行します。

```bash
~]# cd /root/rpmbuild/BUILD/selinux-policy-8f5*f66/
~]# make tomcat.pp
Compiling refpolicy tomcat.mod module
m4 -D distro_redhat -D enable_ubac -D mls_num_sens=16 -D mls_num_cats=1024 -D mcs_num_cats=1024 -D hide_broken_symptoms -s support/divert.m4 policy/support/file_patterns.spt policy/support/ipc_patterns.spt policy/support/obj_perm_sets.spt policy/support/misc_patterns.spt policy/support/misc_macros.spt policy/support/mls_mcs_macros.spt policy/support/loadable_module.spt support/undivert.m4 tmp/generated_definitions.conf tmp/all_interfaces.conf policy/modules/contrib/tomcat.te > tmp/tomcat.tmp
/usr/bin/checkmodule -m tmp/tomcat.tmp -o tmp/tomcat.mod
Creating refpolicy tomcat.pp policy package
/usr/bin/semodule_package -o tomcat.pp -m tmp/tomcat.mod -f tmp/tomcat.mod.fc
```

tomcat.pp を生成したら、既存のポリシーモジュールよりも高い優先度で tomcat.pp を SELinux にインストールします。
既存のポリシーモジュールは優先度が100で登録されているので、それより高い 400 でインストールします。

```bash
~]# semodule -i tomcat.pp -X 400
libsemanage.semanage_direct_install_info: Overriding tomcat module at lower priority 100 with module at priority 400.
Failed to resolve filecon statement at /var/lib/selinux/targeted/tmp/modules/400/tomcat/cil:545
semodule:  Failed!
```

しかし、読み込み時にエラーになりました。
ポリシーモジュールパッケージの内容を CIL で出力して、対象の行 (545行目) を確認します。

```bash
~]# cat tomcat.pp | /usr/libexec/selinux/hll/pp | cat -n
   ...
   545  (filecon "/usr/lib/systemd/system/tomcat.service" file (system_u object_r tomcat_unit_file_t (systemlow systemlow)))
   546  (filecon "/usr/sbin/tomcat(6)?" file (system_u object_r tomcat_exec_t (systemlow systemlow)))
   ...
```

「systemlow」という未知の機密レベルが存在するため、エラーになってしまいました。
この問題は、checkmodule 実行時に -M を付けて、生成したポリシーモジュールパッケージが MLS に対応させることで解決します。
checkmodule 実行時に -M が付くようにビルド時の設定を修正します。
Makefile の中を読むと、TYPE が mls のとき (`ifeq "$(TYPE)" "mls"`)、checkmodule にオプション -M を追加する (`CHECKMODULE += -M`) 処理があります。
また、Makefile の冒頭で build.conf を読み込んでいて (`include build.conf`)、build.conf で変数 TYPE の値を設定しています。
なので、build.conf で TYPE 変数を修正し、`TYPE = mls` に変えて再度コンパイルします。

```bash
~]# cat build.conf | grep TYPE
TYPE = mls
~]# touch ./policy/modules/contrib/tomcat.te
~]# make tomcat.pp
Compiling refpolicy tomcat.mod module
m4 -D enable_mls -D distro_redhat -D enable_ubac -D mls_num_sens=16 -D mls_num_cats=1024 -D mcs_num_cats=1024 -D hide_broken_symptoms -s support/divert.m4 policy/support/file_patterns.spt policy/support/ipc_patterns.spt policy/support/obj_perm_sets.spt policy/support/misc_patterns.spt policy/support/misc_macros.spt policy/support/mls_mcs_macros.spt policy/support/loadable_module.spt support/undivert.m4 tmp/generated_definitions.conf tmp/all_interfaces.conf policy/modules/contrib/tomcat.te > tmp/tomcat.tmp
/usr/bin/checkmodule -M -m tmp/tomcat.tmp -o tmp/tomcat.mod
Creating refpolicy tomcat.pp policy package
/usr/bin/semodule_package -o tomcat.pp -m tmp/tomcat.mod -f tmp/tomcat.mod.fc
```

念のため、/usr/bin/checkmodule -M でビルドしたときの tomcat.pp の中身を CIL 形式で確認してみます。
設定ファイルで `TYPE = mls` にして生成すると、「systemlow」が「s0」に変化して、適切な機密レベル名に修正されました。

```bash
~]# cat tomcat.pp | /usr/libexec/selinux/hll/pp | cat -n
   ...
   545  (filecon "/usr/lib/systemd/system/tomcat.service" file (system_u object_r tomcat_unit_file_t ((s0) (s0))))
   546  (filecon "/usr/sbin/tomcat(6)?" file (system_u object_r tomcat_exec_t ((s0) (s0))))
   ...
```

既存のポリシーモジュールよりも高い優先度で tomcat.pp を SELinux にインストールします。
MLS 対応のポリシーモジュールパッケージだとインストールに成功しました。

```bash
~]# semodule -i tomcat.pp -X 400
~]# semodule -lfull | grep tomcat
400 tomcat            pp
100 tomcat            pp
```

これにより、既存の tomcat ポリシーモジュールは無効化され、追加した tomcat ポリシーモジュールが有効化されました。
sesearch コマンドを使うと、ポリシールールから tomcat_t ドメインが未定義ポート (unreserved_port_t) への接続を許可するルールが削除されたことを確認できます。

修正前：
```bash
~]# sesearch -A -s tomcat_t -t unreserved_port_t -c tcp_socket
allow nsswitch_domain port_type:tcp_socket { recv_msg send_msg }; [ nis_enabled ]:True
allow nsswitch_domain unreserved_port_t:tcp_socket name_bind; [ nis_enabled ]:True
allow nsswitch_domain unreserved_port_t:tcp_socket name_connect; [ nis_enabled ]:True
allow tomcat_domain unreserved_port_t:tcp_socket name_connect;
```

修正後：
```bash
~]# sesearch -A -s tomcat_t -t unreserved_port_t -c tcp_socket
allow nsswitch_domain port_type:tcp_socket { recv_msg send_msg }; [ nis_enabled ]:True
allow nsswitch_domain unreserved_port_t:tcp_socket name_bind; [ nis_enabled ]:True
allow nsswitch_domain unreserved_port_t:tcp_socket name_connect; [ nis_enabled ]:True
```

修正前は「allow tomcat_domain unreserved_port_t:tcp_socket name_connect;」という許可ルールが存在していましたが、組み込みポリシーの修正によって許可ルールを削除することができました。



---

[PRIV](./2-selinux-intro) 
