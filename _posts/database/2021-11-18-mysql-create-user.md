---
layout:        post
title:         "[MySQL] MariaDBでユーザ作成と権限付与をする"
type:          How-To
description:   "MySQLやMariaDBのコンソールでCREATE USERとGRANT ALL PRIVILEGESを実行し、新規データベースユーザーを作成して権限を付与する手順を解説します。"
tags:          [database, mysql, mariadb, user-management, sql]
status:        stable
stale_after:   2027-07-21T00:00:00Z
generated:
  by:          human:tex2e
  at:          2021-11-18T12:42:34Z
date:          2021-11-18
category:      Database
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

MySQLで新規ユーザの作成 (create user) と権限付与 (grant all privileges) する方法について説明します。

まず、MySQLコンソールに接続します。
```bash
~]$ mysql -u root -p
```

次に、create user でユーザを作成し、grant all privileges でDBへのアクセス権を付与します。
```sql
ユーザの作成
mysql> create user ユーザ名@'ホスト名' identified by 'パスワード';

ユーザの権限表示
mysql> show grants for ユーザ名@'ホスト名';

DB一覧の表示
mysql> show databases;

ユーザにDB操作権限を付与
mysql> grant all privileges on DB名.* to ユーザ名@'ホスト名' identified by 'パスワード' with grant option;

ユーザの削除
mysql> drop user ユーザ名@'ホスト名';

ユーザの一覧表示
mysql> select user, host from mysql.user;
```

MySQL内のユーザを作成をしたら、必要に応じてCMSなどのDBの接続情報を修正します。
以下は WordPress と EC-CUBE の設定修正例です。

- WordPress : /var/www/html/wp/wp-config.php
- EC-CUBE : /var/www/html/eccube/data/install.php
```php
defind('DB_USER', 'DBユーザ')
define('DB_PASSWORD', 'DBパスワード')
```
以上です。

