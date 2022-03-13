---
layout:        post
title:         "BINDで再帰問い合わせを無効化する"
date:          2021-11-06
category:      Linux
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

DNSキャッシュサーバとしてBINDを運用する場合は、再帰問い合わせを無効化にすべきです。
再帰問い合わせが有効なDNSサーバを外部に公開していると、DNS増幅攻撃に利用されてしまうからです。
対策として recursion no; に設定することで、再帰問い合わせが無効化されます。

ここでは、再帰問い合わせが有効のときと、無効のときの動作の違いを比較します。

### 再帰問い合わせが有効のとき
まず、BINDをインストールします。
```bash
~]# yum install bind bind-utils
```
次に、named.conf の設定を修正して、別サーバからDNS問い合わせできるようにします。
ip addr コマンドなどで確認しながら、IPアドレスを接続環境のものに合わせ、再帰問い合わせが有効 (`recursion yes;`) になっていることを確認します。

/etc/named.conf
```conf
options {
        #listen-on port 53 { 127.0.0.1; };
        listen-on port 53 { 192.168.56.102; };   # <= 自サーバのIP
        listen-on-v6 port 53 { ::1; };
        directory       "/var/named";
        dump-file       "/var/named/data/cache_dump.db";
        statistics-file "/var/named/data/named_stats.txt";
        memstatistics-file "/var/named/data/named_mem_stats.txt";
        secroots-file   "/var/named/data/named.secroots";
        recursing-file  "/var/named/data/named.recursing";
        #allow-query     { localhost; };
        allow-query     { 192.168.56.0/24; };   # <= 問い合わせ可能な送信元IP

        recursion yes;   # <= 再帰問い合わせが有効
        ...省略...
}

...省略...

zone "example.local" IN {
        type master;
        file "example.local";
        allow-update { none; };
};
```
また、DNS が example.local のゾーンについて正引きできるように設定をします。
named.conf に zone "example.local" の定義を追加し、正引きのファイルを配置します。

/var/named/example.local
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
BINDを再起動します。
```bash
~]# systemctl restart named
```
まずは、server01.example.local の正引きをしてDNSキャッシュサーバとして使えることを確認します。
```bash
]# dig @192.168.56.102 server01.example.local
...省略...
;; QUESTION SECTION:
;server01.example.local.                IN      A

;; ANSWER SECTION:
server01.example.local. 86400   IN      A       192.168.56.101

;; AUTHORITY SECTION:
example.local.          86400   IN      NS      server01.example.local.
```
次に、自分のゾーン以外の正引きをしてみます。
```bash
]# dig @192.168.56.102 example.com
...省略...
;; QUESTION SECTION:
;example.com.                   IN      A

;; ANSWER SECTION:
example.com.            82406   IN      A       93.184.216.34
```
example.com のIPアドレスは 93.184.216.34 であることがわかり、recurseve yes; だと再帰問い合わせが可能であることが確認できました。

### 再帰問い合わせが無効のとき

再帰問い合わせはDNS増幅攻撃に利用されるため、外部からアクセスできるDNSはキャッシュサーバ、内部からはDNSリゾルバのように別サーバに分離することが推奨されています。
DNSキャッシュサーバとして使う場合は recursion no; を設定して、再帰問い合わせを無効化します。

/etc/named.conf
```
options {
        ...省略...

        recursion no;   # <= 再帰問い合わせを無効化する
        ...省略...
}
```
BINDを再起動します。
```bash
~]# systemctl restart named
```
自身のゾーンに対して問い合わせすると期待通り正引きしてくれます。
```bash
~]# dig @192.168.56.102 server01.example.local
...省略...
;; QUESTION SECTION:
;server01.example.local.                IN      A

;; ANSWER SECTION:
server01.example.local. 86400   IN      A       192.168.56.101

;; AUTHORITY SECTION:
example.local.          86400   IN      NS      server01.example.local.
```
一方、自身のゾーンに対して問い合わせしても、再帰問い合わせが発生しないため、正引きできません。
出力結果に status: REFUSED とあり、問い合わせが拒否されたことが確認できます。
```bash
~]# dig @192.168.56.102 example.com
...省略...
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: REFUSED, id: 5904
;; flags: qr rd; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 1
;; WARNING: recursion requested but not available

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 1232
; COOKIE: bbb6ba611839f787ffb3f91f6178b3122ce0c3544e657e4c (good)
;; QUESTION SECTION:
;example.com.                   IN      A
```

DNSキャッシュサーバとしてBINDを運用する場合は、recursion no; に設定して、再帰問い合わせを無効しましょう。

以上です。

