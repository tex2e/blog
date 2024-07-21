---
layout:        post
title:         "[SQLite] データベースを作る方法"
date:          2016-11-21
category:      Database
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from: /db/sqlite-create-db
comments:      false
published:     true
---

SQLiteでデータベースを作る方法について説明します。

まず、作りたいテーブルについてのスキーマを定義したファイルを作成します。

accounts-db-scheme.sql

```sql
create table accounts (
  id char(20) primary key,
  salt varchar(40),
  hashed varchar(40)
);
```

次に、ターミナルで `sqlite3 <データーベース名>` と打つと、そのデーターベースが開く（ない場合は作られる）
ので、先ほど定義したスキーマファイルを流し込みます。

```bash
$ sqlite3 password.db < accounts-db-scheme.sql
```

これで、password というデーターベースの中に、accounts というテーブルが作成されます。


### 参照

- [SQLite3 公式APIドキュメント](https://sqlite.org/fullsql.html)
- [SQlite3 データ型の一覧](https://sqlite.org/datatype3.html)
