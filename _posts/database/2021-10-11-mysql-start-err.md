---
layout:        post
title:         "MySQLが起動できないときの対処 (/var/lib/mysql/ 関連)"
date:          2021-10-11
category:      Database
cover:         /assets/cover1.jpg
redirect_from: /database/mysql-start-error
comments:      true
published:     true
latex:         false
photoswipe:    false
syntaxhighlight: true
# sitemap: false
# feed:    false
---

MySQL を systemctl start mysql を起動できなくなったので、エラーを調べたら /var/lib/mysql/* が悪さをしていたので、その対処法の備忘録です。

まず、mysql を起動するとエラーで起動できません。

```bash
~]# systemctl start mysql
Job for mysql.service failed because the control process exited with error code.
See "systemctl status mysql.service" and "journalctl -xe" for details.
```
/var/log/mysql/error.log に書き込まれたエラーを読むと、/var/lib/mysql が使用不可能であることが書かれています。
```bash
~]# vi /var/log/mysql/error.log
```
記録に書かれてあったエラー：

**The designated data directory /var/lib/mysql/ is unusable. You can remove all files that the server added to it.**

なので、指示通りに削除し、/var/lib/mysql を解放します。
```bash
rm -rf /var/lib/mysql/*
```

再度、mysqlを起動してみますがエラーがでました。
エラーを確認すると、今度は /var/lib/mysql が見つからないから、`mysqld --initialize` を実行してください。という内容でした。
```bash
~]# systemctl start mysql
Job for mysql.service failed because the control process exited with error code.
See "systemctl status mysql.service" and "journalctl -xe" for details.

MySQL system database not found in /var/lib/mysql. Please run mysqld --initialize.
```
初期化してから再度起動します。
```bash
~]# mysqld --initialize
~]# systemctl start mysql
```
正常に起動するようになりました。

以上です。

