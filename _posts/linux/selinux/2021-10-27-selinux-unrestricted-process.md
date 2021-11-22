---
layout:        post
title:         "SELinuxによるコマンドに対する制限を完全に無くす"
menutitle:     "SELinuxによるコマンドに対する制限を完全に無くす (bin_t, unconfined_service_t)"
date:          2021-10-27
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

SELinux環境下でMACの制限を受けないプロセスは unconfined_service_t タイプで実行されてます。
ここでは、httpd のプロセスを制限なしにする方法について説明します。

結論だけ書くと、httpd の場合は `chcon -t bin_t /sbin/httpd` コマンドを実行すれば、SELinuxの制限なしプロセスを呼び出せるようになります。

まず実験のために、SELinux環境下でhttpdがindex.htmlにアクセスできないように、chconコマンドでindex.htmlのタイプをhttpd_sys_content_t以外に変更しておきます。
```bash
~]# chcon -t samba_share_t /var/www/html/index.html
~]# ls -Z /var/www/html/index.html
unconfined_u:object_r:samba_share_t:s0 /var/www/html/index.html
```
クライアント側でアクセスして、httpdの読み取り権限エラーによる403 Forbiddenになることを確認します。
```powershell
PS> (curl http://192.168.56.102/index.html).Content
curl : Forbidden
You don't have permission to access this resource.
```
ここから、httpdプロセスをSELinuxの制限なしに変更していきます。
まず、root権限でssコマンドやfuserコマンドを使って 80/tcp で動作しているプロセスのコマンド名を確認します。
```bash
~]# ss -talpn
State    Recv-Q  Send-Q   Local Address:Port   Peer Address:Port  Process
LISTEN   0       128            0.0.0.0:22          0.0.0.0:*      users:(("sshd",pid=890,fd=5))
LISTEN   0       128                  *:80                *:*      users:(("httpd",pid=3238,fd=4),...)
LISTEN   0       128               [::]:22             [::]:*      users:(("sshd",pid=890,fd=7))
LISTEN   0       128                  *:443               *:*      users:(("httpd",pid=3238,fd=8),...)


~]# fuser -n tcp 80 -v
                     USER        PID ACCESS COMMAND
80/tcp:              root       2879 F.... httpd
                     apache     2882 F.... httpd
                     apache     2883 F.... httpd
                     apache     2884 F.... httpd
                     apache     2885 F.... httpd
```

80/tcpではhttpdコマンドが動作していることがわかったので、コマンドの場所（パス）とSELinuxコンテキストを確認し、/sbin/httpd のタイプを **bin_t** に変更します。
変更後に httpd を再起動すると、unconfined_service_t タイプで動くようになります（変更前は httpd_t タイプ）。
```bash
~]# which httpd
/sbin/httpd

~]# ls -Z /sbin/httpd
system_u:object_r:httpd_exec_t:s0 /sbin/httpd

~]# chcon -t bin_t /sbin/httpd
~]# ls -Z /sbin/httpd
system_u:object_r:bin_t:s0 /sbin/httpd

~]# systemctl restart httpd
~]# systemctl status httpd
* httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; vendor preset: disabled)
   Active: active (running) since Mon 2021-10-25 14:36:02 JST; 7s ago

~]# ps -eZ | grep httpd
system_u:system_r:unconfined_service_t:s0 3232 ? 00:00:00 httpd
system_u:system_r:unconfined_service_t:s0 3234 ? 00:00:00 httpd
system_u:system_r:unconfined_service_t:s0 3235 ? 00:00:00 httpd
system_u:system_r:unconfined_service_t:s0 3236 ? 00:00:00 httpd
system_u:system_r:unconfined_service_t:s0 3237 ? 00:00:00 httpd
system_u:system_r:unconfined_service_t:s0 3238 ? 00:00:00 httpd
```
unconfined_service_t タイプは、SELinux環境下でMACの制限を受けないプロセスなので、index.htmlのSELinuxコンテキストが何であろうと制限を受けず、DACのルールのみでアクセス制御されます。
index.html の権限は 755 なので、問題なく読み取ることができます。
```powershell
PS> (curl http://192.168.56.102/index.html).Content
HELLO
```
ここまでが、プロセスをSELinuxの制限なしにする方法でした。

検証が完了したので、最後に /sbin/httpd のSELinuxコンテキストを元に戻しておきます。
```bash
~]# restorecon -v /sbin/httpd
Relabeled /usr/sbin/httpd from system_u:object_r:bin_t:s0 to system_u:object_r:httpd_exec_t:s0

~]# ls -Z /sbin/httpd
system_u:object_r:httpd_exec_t:s0 /sbin/httpd
```

### 補足：bin_t タイプについて
SELinuxの制限を受けないコマンドは bin_t タイプにラベル付けされています。
bin_t タイプのコマンドを実行すると unconfined_service_t タイプのプロセスが生成されます。
なお、/sbin 直下の各ファイルのコンテキストを確認すると bin_t のものとそれ以外のものが存在することが確認できます。
```bash
~]# ls -Z /sbin
   system_u:object_r:NetworkManager_exec_t:s0 NetworkManager
                   system_u:object_r:bin_t:s0 accessdb
             system_u:object_r:acct_exec_t:s0 accton
                   system_u:object_r:bin_t:s0 adcli
                   system_u:object_r:bin_t:s0 addgnupghome
                   system_u:object_r:bin_t:s0 addpart
                   system_u:object_r:bin_t:s0 adduser
                   ...(省略)...
```
bin_t というタイプ名が思い出せないときは /sbin の中のコンテキストを確認しましょう。

以上です。
