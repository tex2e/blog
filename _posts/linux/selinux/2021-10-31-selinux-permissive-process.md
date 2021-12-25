---
layout:        post
title:         "SELinuxによるドメインに対する制限を無くす"
menutitle:     "SELinuxによるドメインに対する制限を無くす (semanage permissive)"
date:          2021-10-31
category:      Linux
cover:         /assets/cover6.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
syntaxhighlight: true
# sitemap: false
# feed:    false
---

SELinuxにはPermissiveモードという、アクセス拒否ログが出すけどアクセスは許可する、というものがあります。
システム全体をPermissiveにする方法の代わりに、特定のドメイン（プロセスに紐づくタイプ）だけをPermissiveにする方法もあります。

ドメインは ps -eZ でプロセス名の前にある *_t の部分で見ると、わかります。
Apache や Nginx は httpd_t、BIND は named_t など、それぞれ決まったタイプが割り当てられています。

例えば、Apacheが実行するドメイン httpd_t だけを Permissive にする場合は、semanage permissive コマンドを使用します。
実行したら、semanage permissive -l コマンドで登録できたか確認します。
```bash
~]# semanage permissive -a httpd_t
~]# semanage permissive -l

Builtin Permissive Types


Customized Permissive Types

httpd_t
```

<!--
~]# semodule -l | grep permissive
permissive_httpd_t
permissivedomains
-->

続いて、Apacheのサービスを、デフォルトではアクセス拒否される3131番ポートで起動します。
http_port_t に 3131 が含まれていない状態で、httpd.conf を Listen 3131 に修正してから、Apacheを起動します。
```bash
~]# semanage port -l | grep http
http_port_t       tcp      80, 81, 443, 488, 8008, 8009, 8443, 9000
~]# grep ^Listen /etc/httpd/conf/httpd.conf
Listen 3131
~]# systemctl restart httpd
```

このとき、/var/log/audit/audit.log には httpd がポート3131番で起動することを拒否するログが出ます。
```
type=AVC msg=audit(0000000000.520:1607): avc:  denied  { name_bind } for  pid=9247 comm="httpd" src=3131 scontext=system_u:system_r:httpd_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=1
```
しかし、httpdは問題なく起動できています。
```bash
~]# systemctl status httpd
* httpd.service - The Apache HTTP Server
   Loaded: loaded (/usr/lib/systemd/system/httpd.service; disabled; vendor preset: disabled)
   Active: active (running)
```
以上、特定のドメインだけをPermissiveにする方法でした。

/var/log/audit/audit.log に書かれたアクセス拒否ログから、例外ルールを作りたい場合は sealert コマンドの実行結果の提案 (suggests) を参考にしながら、ポリシーを修正していきます。

```bash
~]# sealert -l '*'
```

最後に、元に戻すために httpd_t の Permissive の設定を削除する場合は、-d オプションで実行します。
```bash
~]# semanage permissive -d httpd_t
libsemanage.semanage_direct_remove_key: Removing last permissive_httpd_t module (no other permissive_httpd_t module exists at another priority).
~]# semanage permissive -l
~]#
```

以上です。
