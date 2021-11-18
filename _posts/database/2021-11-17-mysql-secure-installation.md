---
layout:        post
title:         "mysql_secure_installationでMySQLから不要なユーザを削除する"
date:          2021-11-17
category:      Database
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

mysql_secure_installationコマンドを利用してMySQLの不要なユーザ（匿名ユーザとリモートからアクセスできるrootユーザ）を削除する方法について説明します。

まず、MySQLコンソールに接続します。
```bash
~]$ mysql -u root -p
```

次に現状のMySQLユーザ一覧を表示します。
userの列が空白のものは、匿名ログインが可能であることを表しています。
hostの列は接続可能な接続元を表しており、% は全ての IP またはホストからの接続を許可することを表しています。
```
mysql> select user, host from mysql.user;
+------+-------------+
| user | host        |
+------+-------------+
| root | localhost   |
| root | centos63    |
| root | 127.0.0.1   |
|      | localhost   |
|      | centos63    |
| root | %           |
| root | 192.168.%.% |
| root | 10.%.%.%    |
| root | 127.%.%.%   |
+------+-------------+
9 rows in set (0.00 sec)
```

不要なユーザは mysql_secure_installation コマンドで削除することができます。
mysql_secure_installation コマンドでは root ユーザのパスワード変更、匿名ユーザアカウントの削除、ローカルホスト以外からアクセス可能なrootアカウントを削除、test データベースの削除 などを行います。
```bash
~]# mysql_secure_installation
```
実行時の質問：
```
rootパスワードの変更
Change the root password? [Y/n] n
匿名ログインの無効化
Remove anonymous users? [Y/n] Y
リモートからのrootログインを無効化
Disallow root login remotely? [Y/n] Y
テストDBの削除
Remove test database and access to it? [Y/n] n
権限テーブルのリロード
Reload privilege tables now? [Y/n] Y
```

匿名ログインの無効化すると、userが空白である行が削除されます。
匿名ログインの無効化した後のユーザテーブルは以下のようになります。
```
mysql> select user, host from mysql.user;
+------+-------------+
| user | host        |
+------+-------------+
| root | localhost   |
| root | centos63    |
| root | 127.0.0.1   |
| root | %           |
| root | 192.168.%.% |
| root | 10.%.%.%    |
| root | 127.%.%.%   |
+------+-------------+
```
また、リモートからのrootログインを無効化すると、hostがlocalhostと127.0.0.1以外の行が削除されます。
リモートからのrootログインを無効化した後のユーザテーブルは以下のようになります。
```
mysql> select user, host from mysql.user;
+------+-------------+
| user | host        |
+------+-------------+
| root | localhost   |
| root | 127.0.0.1   |
+------+-------------+
```
以上です。

