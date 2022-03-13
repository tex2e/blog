---
layout:        post
title:         "ポート番号を変更したBINDをSELinuxで許可する"
menutitle:     "ポート番号を変更したBINDをSELinuxで許可する (dns_port_t)"
date:          2021-11-08
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

BINDでポート番号を変更する際に、SELinuxの設定も変更する方法について説明します。

まず、named.confの内容を修正して、BINDのポート番号を53から5353に変更します。

/etc/named.conf
```bash
options {
        #listen-on port 53 { 192.168.56.102; };
        listen-on port 5353 { 192.168.56.102; };
        #listen-on-v6 port 53 { ::1; };
        listen-on-v6 port 5353 { ::1; };
```
BIND (named) を再起動します。
```bash
~]# systemctl restart named
```
named は起動しますが、messagesやaudit.logにはエラーログが記録されます。
```bash
~]# grep "SELinux is preventing" /var/log/messages
```
/var/log/messages のログ例：
```
localhost setroubleshoot[1700]: SELinux is preventing /usr/sbin/named from name_bind access on the tcp_socket port 5353. For complete SELinux messages run: sealert -l b988ce0c-a019-48e2-9ce8-07cd7602b766
```
audit.logに記録されたアクセス拒否のログは次のコマンドで確認します。
```bash
~]# tail /var/log/audit/audit.log | grep denied
```
/var/log/audit/audit.log のログ例：
```
type=AVC msg=audit(0000000000.773:166): avc:  denied  { name_bind } for  pid=1756 comm="isc-worker0000" src=5353 scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:unreserved_port_t:s0 tclass=tcp_socket permissive=0
```
アクセス拒否されましたが、プロセス自体は5353番ポートで起動できているようです（named は起動できたが、isc-worker0000 は起動できなかったか？）。
```bash
~]# ss -ualpn
State    Recv-Q  Send-Q   Local Address:Port   Peer Address:Port  Process
UNCONN   0       0       192.168.56.102:5353       0.0.0.0:*      users:(("named",pid=1756,fd=512))
UNCONN   0       0                [::1]:5353          [::]:*      users:(("named",pid=1756,fd=513))
```
digでも問題なくDNS問い合わせができます。
```bash
~]# dig @192.168.56.102 server01.example.local -p 5353
...省略...
;; QUESTION SECTION:
;server01.example.local.                IN      A

;; ANSWER SECTION:
server01.example.local. 86400   IN      A       192.168.56.101

;; AUTHORITY SECTION:
example.local.          86400   IN      NS      server01.example.local.
```

SELinuxでは特定のプロセスに対するポートを許可する設定があるので、その設定を行います。
まず、/var/log/messages のログに書かれてあるSELinuxメッセージのIDでトラブルシューティングをします。
```bash
~]# sealert -l "b988ce0c-a019-48e2-9ce8-07cd7602b766"
```
named が 5353 番ポートを開くときにアクセス拒否されたことについて、semanage port で 5353 番ポートを許可すれば良いことが提案 (suggests) を読むとわかります。
```
SELinux is preventing /usr/sbin/named from name_bind access on the tcp_socket port 5353.

*****  Plugin bind_ports (92.2 confidence) suggests   ************************

If you want to allow /usr/sbin/named to bind to network port 5353
Then you need to modify the port type.
Do
# semanage port -a -t PORT_TYPE -p tcp 5353
    where PORT_TYPE is one of the following: certmaster_port_t, cluster_port_t, dns_port_t, ephemeral_port_t, hadoop_datanode_port_t, hplip_port_t, isns_port_t, postgrey_port_t, rndc_port_t.

...省略...
```
dns_port_t タイプにポート 5353 番を追加します。
```bash
~]# semanage port -a -t dns_port_t -p tcp 5353
~]# semanage port -a -t dns_port_t -p udp 5353
~]# semanage port -l | grep dns_port_t
dns_port_t                     tcp      5353, 53, 853
dns_port_t                     udp      5353, 53, 853
```
追加するときに、既に登録済みで登録失敗になるときがあります。
そのときは、プロトコル(tcp/udp)とポート番号の組み合わせがすでに他のタイプに紐づいている場合です。
```bash
~]# semanage port -a -t dns_port_t -p udp 5353
ValueError: Port udp/5353 already defined

~]# semanage port -l | grep 5353
howl_port_t                    udp      5353
```
SELinuxはポートが常にuniqueになるため、すでに存在する登録されているポート番号を追加 (-a) することはできません。
代わりに、ポート番号への対応付けを修正 (-m) オプションにして追加します。
```bash
~]# semanage port -m -t dns_port_t -p udp 5353
~]# semanage port -l | grep 5353
dns_port_t                     udp      5353, 53, 853
howl_port_t                    udp      5353
```
設定したらBINDを再起動します。適切に設定できていればアクセス拒否のログは追加されなくなります。
```bash
~]# systemctl restart named
```
以上です。
