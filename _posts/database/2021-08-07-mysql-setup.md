---
layout:        post
title:         "MySQLへ外部からの接続するための手順"
date:          2021-08-07
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

UbuntuでMySQLへ外部からの接続するための手順を備忘録としてまとめておきます。

ます、UbuntuにMySQLをインストールする。

```bash
$ sudo apt install mysql-server mysql-client
$ sudo mysql_secure_installation
```

```
LOW    Length >= 8
MEDIUM Length >= 8, numeric, mixed case, and special characters
STRONG Length >= 8, numeric, mixed case, special characters and dictionary file

Please enter 0 = LOW, 1 = MEDIUM and 2 = STRONG:
 1

Please set the password for root here.
New password: (新規パスワード入力)
Re-enter new password: (新規パスワード入力)

Do you ...snip...?(Press y|Y for Yes, any other key for No) : Y
```

MySQLインストール時の最後にY/Nがあるので、基本的にYで答える。

- 匿名MySQLユーザーを削除するか
- テストデータベースを削除するか
- リモートrootログインを禁止するか

mysqlのコンソールに入り、MySQL接続用ユーザを作る。

```bash
$ sudo mysql
```

```sql
CREATE USER username@'%' IDENTIFIED BY 'password';
```

初期状態ではshow grantsで「GRANT USAGE」は何も権限がない状態なので、
ユーザ名 username に全DBの全テーブルの管理者権限を与える。
接続元は「%」にすると全てのIPからの接続を受け入れるが、気になる場合は接続元IPを指定する。

```sql
show grants for username@'%';
grant all on *.* to username@'%';
```

MySQLの設定ファイルを編集する。
/etc/mysql/mysql.conf.d/mysqld.cnf を編集してmysqlがLISTENするべきホスト名を指定する。

```
bind-address = 192.168.xx.xx
mysqlx-bind-address = 192.168.xx.xx
```

mysqlの設定後、サービス再起動する。

```
sudo systemctl restart mysql
```

mysqldが自身のサーバのIPアドレスでLISTENしているか確認する。

```bash
$ sudo ss -talpn

LISTEN     192.168.xx.xx:3306     users:(("mysqld",pid=6337,fd=24))
```

（必要に応じて）ファイアウォールをufwでMySQLの3306番を開ける。

```
$ sudo ufw status
$ sudo ufw allow 3306
```

あとは、SQLクライアントで種類を「MySQL/MariaDB」、接続先「192.168.xx.xx」、ユーザ名「username」、パスワード「password」にすれば接続できると思います。



### 参考文献

- [Ubuntu 20.04にMySQLをインストールする方法 \| DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-install-mysql-on-ubuntu-20-04-ja)
- [ufwコマンドの使い方 - Qiita](https://qiita.com/hana_shin/items/a630871dce209cff04f3#5-%E3%83%AB%E3%83%BC%E3%83%AB%E3%81%AE%E8%BF%BD%E5%8A%A0%E5%89%8A%E9%99%A4%E6%96%B9%E6%B3%95)
