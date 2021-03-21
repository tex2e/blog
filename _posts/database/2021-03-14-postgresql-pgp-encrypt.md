---
layout:        post
title:         "PostgreSQLで共通鍵によるデータ暗号化・復号"
date:          2021-03-14
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

PostgreSQLのpgcrypto拡張を使った共通鍵によるデータの暗号化と復号の方法について説明します。

まず、psql などでDBに接続してから、暗号の拡張をインストールします。

```sql
create extension pgcrypto;
```

インストールされているかは、pgp から始まる関数一覧に表示されているかで確認できます。

```sql
\df pgp_*
```

```psql
mydb=# \df pgp_*
                                       List of functions
 Schema |         Name          | Result data type |        Argument data types         | Type
--------+-----------------------+------------------+------------------------------------+------
 public | pgp_armor_headers     | SETOF record     | text, OUT key text, OUT value text | func
 public | pgp_key_id            | text             | bytea                              | func
 public | pgp_pub_decrypt       | text             | bytea, bytea                       | func
 public | pgp_pub_decrypt       | text             | bytea, bytea, text                 | func
 public | pgp_pub_decrypt       | text             | bytea, bytea, text, text           | func
 public | pgp_pub_decrypt_bytea | bytea            | bytea, bytea                       | func
 public | pgp_pub_decrypt_bytea | bytea            | bytea, bytea, text                 | func
 public | pgp_pub_decrypt_bytea | bytea            | bytea, bytea, text, text           | func
 public | pgp_pub_encrypt       | bytea            | text, bytea                        | func
 public | pgp_pub_encrypt       | bytea            | text, bytea, text                  | func
 public | pgp_pub_encrypt_bytea | bytea            | bytea, bytea                       | func
 public | pgp_pub_encrypt_bytea | bytea            | bytea, bytea, text                 | func
 public | pgp_sym_decrypt       | text             | bytea, text                        | func
 public | pgp_sym_decrypt       | text             | bytea, text, text                  | func
 public | pgp_sym_decrypt_bytea | bytea            | bytea, text                        | func
 public | pgp_sym_decrypt_bytea | bytea            | bytea, text, text                  | func
 public | pgp_sym_encrypt       | bytea            | text, text                         | func
 public | pgp_sym_encrypt       | bytea            | text, text, text                   | func
 public | pgp_sym_encrypt_bytea | bytea            | bytea, text                        | func
 public | pgp_sym_encrypt_bytea | bytea            | bytea, text, text                  | func
(20 rows)
```

今回は、共通鍵暗号の pgp_sym_encrypt と pgp_sym_decrypt を使います。

暗号化データは bytea (バイナリ列データ型) で定義します。

```sql
create table users (id int not null primary key, secret bytea, email bytea);
```

パスワードは、SQL関数で定義しておきます（パスワードの保存方法については要検討）。

```sql
create function get_passwd() returns text as $$
    select cast('P4ssW0rd' as text);
    $$ language sql immutable;
```

SQL関数定義時における IMMUTABLE は、関数がデータベースに変更せず、同じ引数を与えたときは常に同じ結果を返すことを表します。

次に、暗号化データをテーブルにInsertします。

```sql
insert into users(id, secret, email)
values (1, pgp_sym_encrypt('Secret Message!', get_passwd()), 
           pgp_sym_encrypt('a@a.com', get_passwd()));
```

テーブルには暗号化データが格納されます。

```sql
select * from users;
```

```psql
 id |                                                                                secret                                                                                |                                                                        email
----+----------------------------------------------------------------------------------------------------------------------------------------------------------------------+------------------------------------------------------------------------------------------------------------------------------------------------------
  1 | \xc30d04070302ce6d6707a71f33726ad240013e5b7e51b641043f6b04ad027e4e099c2a4210c8b7759d331d78c532ce6d0caeed398389b90bee11e365fcd5501d5bccb5a752bfe55be3697958455ea9e38b | \xc30d0407030290f567b015cfe3097bd238010c64339e7b1cd6a28a8464144824714416f38b51d1686d678365ba9ac1f672664ede989a21a15320f5c5c6ea9bd3b7047e70798cb2fc58
(1 row)
```

復号は暗号化と同様にできます。

```sql
select id, pgp_sym_decrypt(secret, get_passwd()) as secret, 
           pgp_sym_decrypt(email, get_passwd()) as email
  from users;
```

```psql
 id |     secret      |  email
----+-----------------+---------
  1 | Secret Message! | a@a.com
(1 row)
```


### PGP暗号化関数

PGP暗号化関数で暗号化されたメッセージは2つの文字列から構成されます。

1. セッション鍵に関する情報（ソルトや暗号化アルゴリズムなど）
2. セッション鍵で暗号化されたデータ

セッション鍵を生成するときは、内部的に生成したソルトと与えられたパスワードから鍵導出アルゴリズムで生成しているため、
同じ平文でも暗号化する毎に異なる暗号文が出力されます。


```sql
select pgp_sym_encrypt('test text', get_passwd());
select pgp_sym_encrypt('test text', get_passwd());
select pgp_sym_encrypt('test text', get_passwd());
select pgp_sym_encrypt('test text', get_passwd());
select pgp_sym_encrypt('test text', get_passwd());
```

上のように同じ平文を暗号化しても、下のように別の暗号文が生成されます。

```psql
                                                                     pgp_sym_encrypt

----------------------------------------------------------------------------------------------------------------------------------------------------------
 \xc30d040703028341d8ace2c575b16cd23a0174f4ed4a9e9bc6f8261e43ec6586582fc3ae07a42cb861c9fd64e80c85573f4ffb8b032d8cf41ad5d25b953f461545238dc1e13619efccfec5

 \xc30d040703029a134d15ab5f1fd662d23a01efdf3f3595cedbae82c7435118564f21043bbfbb4b363a2508f8147d139a30cd058ba748237f2f7c714707ca322f6894e72776f710db8bfae0

 \xc30d040703023c124baa90124ccd68d23a0186ef03b984c64ef485a84eb4113959b163bf23c774ff03615079eb492f086028856649961a51174cc758a3e2c232d8a7d25f11a57caff3d630

 \xc30d040703020a167526bedb6f276bd23a01fc512e11cf309aa66eaab2938aaa91e911251db020cbb7df23da823bbade50e8b02820643e550fd910404c15e25457bb6c4eef6a69f6b5af6a

 \xc30d04070302b9c992796f8183007dd23a01127dda549ad8ccfc06d3578fc40c92ac74b1799f9ac6c2671811e4e6dfba7589a579832f03158045b4eddf6ced0a3ab2fb601b770801666717
```

よって、pgp_sym_encrypt を使えば、自前でソルト（salt）が追加されるため、ソルトのカラムをテーブルに追加する必要がなくなります。


### 参考文献

- [pgcrypto (日本語)](https://www.postgresql.jp/document/9.4/html/pgcrypto.html)
- [PostgreSQL: Documentation: 9.3: pgcrypto (英語公式)](https://www.postgresql.org/docs/9.3/pgcrypto.html)
- [RDS for PostgreSQLでデータを暗号化する \| DevelopersIO](https://dev.classmethod.jp/articles/data-encryption-on-rds-for-postgresql/)
- [PostgreSQLでpgcryptoを使ったデータ暗号化 - Qiita](https://qiita.com/niharu/items/f812ca3ba924ed94eefd)
- [Ubuntu 20.04にPostgreSQLをインストールする方法 \[クイックスタート\] \| DigitalOcean](https://www.digitalocean.com/community/tutorials/how-to-install-postgresql-on-ubuntu-20-04-quickstart-ja)
- [CREATE FUNCTION](https://www.postgresql.jp/document/9.2/html/sql-createfunction.html)
