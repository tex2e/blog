---
layout:        post
title:         "Apacheの起動時のユーザ権限を確認する"
date:          2021-11-24
category:      Linux
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

通常、Apacheを起動すると apache ユーザとしてプロセスが起動されますが、設定ミスなどで root ユーザになっていると大変危険です。
もし root になっていると、Webアプリに脆弱性があって任意のOSコマンドが実行できる場合に、システム権限を掌握されます。
ここでは、Apacheの設定ファイルで起動ユーザが apache になっているか確認する方法を説明します。

確認方法は、以下のコマンドを実行して、apacheと出力されることを確認します。
apache であれば通常の安全な設定になっています。
```bash
~]# grep -i '^User' /etc/httpd/conf/httpd.conf
User apache
~]# grep -i '^Group' /etc/httpd/conf/httpd.conf
Group apache
```

もし root などになっている場合は修正します。修正方法は、/etc/httpd/conf/httpd.conf を以下のように修正します。
```
User apache
Group apache
```

以上です。

#### 参考文献
- [CIS Downloads > Apache](https://downloads.cisecurity.org/#/)
