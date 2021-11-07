---
layout:        post
title:         "Nginxでリバースプロキシ"
date:          2021-11-11
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

Nginxを使って、同一サーバ内でリバースプロキシをするための設定について説明します。
ここでは、80番ポートへのアクセスを3131番ポートに繋ぐ方法を説明します。

まず、設定ファイル nginx.conf を修正して、upstream にフォワード先を指定します。
そして、location の中に proxy_pass を指定します。

/etc/nginx/nginx.conf
```conf
http {
    ...

    upstream myapp {
        server 127.0.0.1:3131;
    }

    server {
        listen  80 default_server;

        location / {
            proxy_pass http://myapp;
        }
    }
}
```
nginxの設定をしたら、サービスを起動させて、ssコマンドで 80 と 3131 が LISTEN になっていることを確認します。

```bash
~]# systemctl restart nginx

~]# ss -talpn
State   Recv-Q  Send-Q  Local Address:Port  Peer Address:Port  Process
LISTEN  0       128           0.0.0.0:80         0.0.0.0:*      users:(("nginx",pid=2416,fd=8),("nginx",pid=2415,fd=8))
LISTEN  0       128                 *:3131             *:*      users:(("httpd",pid=2223,fd=4),("httpd",pid=1765,fd=4),("httpd",pid=1764,fd=4),...)
```
Apache側のアクセスログを開いておきます。
```bash
~]# tail -f /var/log/httpd/access_log
```
curlでNginxのリバースプロキシにアクセスします。
```bash
~]$ curl 127.0.0.1/
```

### SELinuxが有効な場合

SELinuxが有効になっている場合、Nginxプロセスは httpd_t タイプに紐づけられており、デフォルトでは別ホストやポートへのネットワーク接続ができません。
Nginxをプロキシサーバとして動かす際は、ブール値 httpd_can_network_relay を On にするだけで、SELinuxで許可されるようになります。
```bash
~]# setsebool -P httpd_can_network_relay 1
```

その他SELinux関連で問題がある場合は、sealertコマンドでアクセス拒否の有無を確認します。
```bash
~]# sealert -l "*"
```
以下のような出力・提案があれば、指示通りに従ってSELinuxのアクセス許可を実施します。
```
SELinux により、nginx による name_connect アクセスが、tcp_socket port 3131 で拒否されました。

...省略...

*****  プラグイン catchall_boolean (24.7 信頼性) による示唆********************************

allow httpd to can network relay をする場合
このようにします: 'httpd_can_network_relay' boolean を有効にして、 これを SELinux で有効にします。

そして、以下を実行します: 
setsebool -P httpd_can_network_relay 1
```
以上です。


#### 参考文献
- [Nginxのロードバランシング機能を使ってみよう！ - 株式会社ネディア \│ ネットワークの明日を創る。](https://www.nedia.ne.jp/blog/tech/2016/08/04/7938)
- [14.3. Booleans Red Hat Enterprise Linux 7 \| Red Hat Customer Portal](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/selinux_users_and_administrators_guide/sect-managing_confined_services-the_apache_http_server-booleans)
