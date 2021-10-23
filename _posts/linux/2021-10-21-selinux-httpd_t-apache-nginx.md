---
layout:        post
title:         "ApacheとNginxプロセスのSELinuxコンテキスト (httpd_tタイプ) について"
menutitle:     "[SELinux] ApacheとNginxプロセスのSELinuxコンテキスト (httpd_tタイプ) について"
date:          2021-10-21
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

結論としては、SELinux上ではApacheもNginxも同じタイプ「httpd_t」です。
そのため、使用できるポートを管理するタイプ http_port_t や外部サーバのDBに接続するためのブール値 httpd_can_network_connect_db などは、Apache と Nginx の両方に適用されます。

確認のために、プロセスに対してSELinuxコンテキストを表示させています。`ps -e` は全プロセス情報を表示するコマンドで、`ps -eZ` はそこに追加でプロセスのSELinuxコンテキストを表示するためのコマンドです。

#### Apache
```bash
~]# systemctl start httpd
~]# ps -eZ | grep httpd
system_u:system_r:httpd_t:s0       3818 ?        00:00:00 httpd
system_u:system_r:httpd_t:s0       3820 ?        00:00:00 httpd
system_u:system_r:httpd_t:s0       3821 ?        00:00:00 httpd
system_u:system_r:httpd_t:s0       3822 ?        00:00:00 httpd
system_u:system_r:httpd_t:s0       3823 ?        00:00:00 httpd
system_u:system_r:httpd_t:s0       3824 ?        00:00:00 httpd
system_u:system_r:httpd_t:s0       4050 ?        00:00:00 httpd
```

#### Nginx
```bash
~]# systemctl start nginx
~]# ps -eZ | grep nginx
system_u:system_r:httpd_t:s0       4304 ?        00:00:00 nginx
system_u:system_r:httpd_t:s0       4305 ?        00:00:00 nginx
```

Apache と Nginx どちらもプロセスは httpd_t タイプにラベル付けされています。

以上です。
