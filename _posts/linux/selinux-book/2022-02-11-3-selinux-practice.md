---
layout:        book
title:         "3. SELinux/SELinuxの実践"
date:          2022-02-11
category:      Linux
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    true
syntaxhighlight: true
sitemap: false # 後で公開すること!
feed:    false # 後で公開すること!
---

**[WIP] この記事は書き途中です。完成までしばらくお待ちください。**

### SELinuxを有効化する

TODO:

https://tex2e.github.io/blog/linux/enable-selinux

### httpdがファイル書き込み可能にする

TODO:

https://tex2e.github.io/blog/linux/httpd_sys_rw_content_t

### httpdがファイル実行可能にする

TODO:

### SELinuxでWebサーバ経由の侵入攻撃を防ぐ

TODO:

https://tex2e.github.io/blog/linux/selinux-and-php-backdoor

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
~]# echo 'type=AVC msg=audit(0000000000.719:695): avc:  denied  { entrypoint } for  pid=10457 comm="(python3)" path="/usr/libexec/platform-python3.6" dev="dm-0" ino=35081046 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:bin_t:s0 tclass=file permissive=0' | audit2allow

#============= httpd_t ==============
allow httpd_t bin_t:file entrypoint;
```

追加するポリシールールを確認したら、ポリシーパッケージを作成します。
作り方は、audit2allow のオプションに -M でモジュール名を指定して実行すると、.pp という拡張子のポリシーパッケージが作成されます。
それを SELinux のモジュールに追加するには semodule -i でモジュールをインストールします。
```bash
~]# echo 'type=AVC msg=audit(0000000000.719:695): avc:  denied  { entrypoint } for  pid=10457 comm="(python3)" path="/usr/libexec/platform-python3.6" dev="dm-0" ino=35081046 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:bin_t:s0 tclass=file permissive=0' | audit2allow -M simplehttpserver

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
以上で、自作サービスのPython3の簡易Webサーバを、httpd_t ドメインとしてアクセス制御することができました。

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

```bash
systemctl daemon-reload
systemctl start simplehttpserver
systemctl status simplehttpserver
```

```bash
~]# semanage fcontext -a -t httpd_exec_t '/usr/libexec/platform-python[0-9]+\.[0-9]+_simplehttpserver'
~]# restorecon -v /usr/libexec/platform-python*
```


### 既存の組み込みポリシーを修正する

TODO:



---

[PRIV](./2-selinux-intro) 
