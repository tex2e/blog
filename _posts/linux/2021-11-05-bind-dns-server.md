---
layout:        post
title:         "BINDによるDNSサーバの構築"
date:          2021-11-05
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

CentOSでBINDでDNSサーバを立てて、正引きと逆引きと設定と、digやnslookupコマンドによる確認方法について説明します。

まず、BINDをインストールします。インストール時は bind ですが、サービス名は named です。
```bash
~]# yum install bind
~]# systemctl start named
```
次に設定ファイルを修正して、待ち受けIPアドレス (listen-on) と問い合わせ可能IPアドレス (allow-query) を設定します。
また、ここではテストで example.local というゾーンを定義します。

/etc/named.conf
```conf
options {
        #listen-on port 53 { 127.0.0.1; };
        listen-on port 53 { 192.168.56.102; };
        listen-on-v6 port 53 { ::1; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        secroots-file   "/var/named/data/named.secroots";
        recursing-file  "/var/named/data/named.recursing";
        #allow-query     { localhost; };
        allow-query     { 192.168.56.0/24; };

        recursion yes;  # 外部に公開する場合はnoに変更すること（DNS増幅攻撃への対策）

        dnssec-enable yes;
        dnssec-validation yes;

        managed-keys-directory "/var/named/dynamic";

        pid-file "/run/named/named.pid";
        session-keyfile "/run/named/session.key";

        /* https://fedoraproject.org/wiki/Changes/CryptoPolicy */
        include "/etc/crypto-policies/back-ends/bind.config";
};

logging {
        channel default_debug {
                file "data/named.run";
                severity dynamic;
        };
};

zone "." IN {
        type hint;
        file "named.ca";
};

# 正引き
zone "example.local" IN {
        type master;
        file "example.local";
        allow-update { none; };
};

# 逆引き
zone "56.168.192.in-addr.arpa" {
      type master;
      file "example.local.rev";
};

include "/etc/named.rfc1912.zones";
include "/etc/named.root.key";
```

次に、正引きと逆引きをするためのファイルを配置します。
正引きでは、server01.example.local を正引きすると 192.168.56.101 になるように設定ファイルを書きます。

/var/named/example.local （正引き用ファイル）
```
$TTL      86400
@         IN       SOA     server01.example.local.  root.example.local.(
                                        2020020501 ; Serial
                                        28800      ; Refresh
                                        14400      ; Retry
                                        3600000    ; Expire
                                        86400 )    ; Minimum
            IN NS server01.example.local.
server01    IN A 192.168.56.101
server02    IN A 192.168.56.102
```

逆引きでは、192.168.56.101 を逆引きすると server01.example.local が得られるように設定ファイルを書きます。

/var/named/example.local.rev （逆引き用ファイル）
```
$TTL      86400
@         IN       SOA     server01.example.local.  root.example.local.(
                                        2020020501 ; Serial
                                        28800      ; Refresh
                                        14400      ; Retry
                                        3600000    ; Expire
                                        86400 )    ; Minimum
      IN NS server01.example.local.
101   IN PTR server01.example.local.
102   IN PTR server02.example.local.
```

設定後は named-checkconf でBINDの設定が正しいか確認してから、named.confとゾーン情報をリロードします。
起動後は、namedが53/udpで起動しているか確認します。
```bash
~]# named-checkconf
~]# rndc reload
~]# ss -ualpn
State    Recv-Q   Send-Q    Local Address:Port   Peer Address:Port   Process
UNCONN   0        0        192.168.56.102:53          0.0.0.0:*       users:(("named",pid=10870,fd=512))
UNCONN   0        0                 [::1]:53             [::]:*       users:(("named",pid=10870,fd=513))
```

別のPCやサーバからDNS問い合わせをする際はFirewallを修正して、53/udp のパケットが通過できるように設定します。
```bash
~]# firewall-cmd --add-service=dns --permanent
~]# firewall-cmd --reload
~]# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: enp0s3 enp0s8
  sources:
  services: cockpit dhcpv6-client dns ssh
  ...省略...
```

#### 正引き
準備ができたら dig でDNS問い合わせをしてみます。
PCの設定で問い合わせ先のDNSを変更するのは面倒なので、digの @ で問い合わせ先DNSサーバのIPを指定して問い合わせます。
コマンドを入力すると以下のように server01.example.local を正引きすると 192.168.56.101 であることがわかりました。
```bash
~]$ dig @192.168.56.102 server01.example.local
;; QUESTION SECTION:
;server01.example.local.                IN      A

;; ANSWER SECTION:
server01.example.local. 86400   IN      A       192.168.56.101

;; AUTHORITY SECTION:
example.local.          86400   IN      NS      server01.example.local.
```
nslookup を使う場合は、2番目の引数にDNSサーバのIPを指定します。
```bash
~]$ nslookup server01.example.local 192.168.56.102
Server:         192.168.56.102
Address:        192.168.56.102#53

Name:   server01.example.local
Address: 192.168.56.101
```

#### 逆引き
digで逆引きする場合は -x オプションでIPを指定します。
```bash
~]$ dig @192.168.56.102 -x 192.168.56.101
...省略...
;; QUESTION SECTION:
;101.56.168.192.in-addr.arpa.   IN      PTR

;; ANSWER SECTION:
101.56.168.192.in-addr.arpa. 86400 IN   PTR     server01.example.local.

;; AUTHORITY SECTION:
56.168.192.in-addr.arpa. 86400  IN      NS      server01.example.local.

;; ADDITIONAL SECTION:
server01.example.local. 86400   IN      A       192.168.56.101
```
nslookup を使う場合は、1番目の引数に逆引きしたいIPを指定して実行します。
```bash
~]$ nslookup 192.168.56.101 192.168.56.102
101.56.168.192.in-addr.arpa     name = server01.example.local.
```
以上です。
