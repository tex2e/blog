---
layout:        post
title:         "Nginxの起動時のユーザ権限を確認する"
date:          2021-11-25
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

通常、Nginxを起動すると nginx ユーザとしてプロセスが起動されますが、設定ミスなどで root ユーザになっていると大変危険です。
もし root になっていると、Webアプリに脆弱性があって任意のOSコマンドが実行できる場合に、システム権限を掌握されます。
ここでは、Nginxの設定ファイルで起動ユーザが nginx になっているか確認する方法を説明します。

確認方法は、以下のコマンドを実行して、nginxと出力されることを確認します。
nginx であれば通常の安全な設定になっています。
```bash
~]# grep "^user[^;]*;" /etc/nginx/nginx.conf
user nginx;
```

もし root などになっている場合は修正します。修正方法は、/etc/nginx/nginx.conf を以下のように修正します。
```
user nginx;
```

以上です。

#### 参考文献
- [CIS Downloads > Nginx](https://downloads.cisecurity.org/#/)
