---
layout:        post
title:         "MySQL (MariaDB) でユーザ作成と権限付与をする"
date:          2021-11-18
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

