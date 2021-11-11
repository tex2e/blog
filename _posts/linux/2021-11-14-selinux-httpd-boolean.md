---
layout:        post
title:         "httpd に関するSELinuxブール値"
date:          2021-11-14
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

httpd のSELinuxブール値のOn/Offを切り替えることで、自分の手でSELinuxポリシーをチューニングする必要がなくなります。
以下はよく使う httpd に関する SELinux のブール値の一覧と簡単な説明です。

| ブール値の名前 | デフォルト値 | 説明
|---|---|---
| **httpd_builtin_scripting** | on | PHPコンテンツなどのスクリプトへのアクセスを許可する
| **httpd_can_network_connect** | off | リモートポートへの接続を許可する
| **httpd_can_network_connect_db** | off | データベースサーバーへの接続を許可する
| **httpd_can_network_relay** | on | リバースプロキシとして使用することを許可する
| **httpd_can_sendmail** | off | メールの送信を許可する
| **httpd_enable_cgi** | on | httpd_sys_script_exec_t タイプでラベル付けされたCGIスクリプトの実行を許可する
| **httpd_enable_homedirs** | off | ユーザのホームディレクトリへのアクセスを許可する

設定は以下のコマンドで実行できます。
```bash
~]# setsebool -P httpd_can_network_connect_db on
```

以上です。

#### 参考文献
- [14.3. ブール値 Red Hat Enterprise Linux 7 \| Red Hat Customer Portal](https://access.redhat.com/documentation/ja-jp/red_hat_enterprise_linux/7/html/selinux_users_and_administrators_guide/sect-managing_confined_services-the_apache_http_server-booleans)
