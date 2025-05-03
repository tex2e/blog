---
layout:        post
title:         "[SQLServer] テーブルに列を追加する方法"
date:          2025-04-23
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

SQL Serverでテーブルに列を追加するためによく使うSQLのテンプレを紹介します。
SQLの処理の流れとしては、以下の通りです。

1. テーブルを別名にする (exec sp_rename)
2. 新テーブルを作成する (create table)
3. 旧テーブルから新テーブルに移行する (insert into)
4. 旧テーブルを削除する (drop table)

テンプレのSQLは以下の通りです。TARGETTABLEのテーブル名だけ処理対象のテーブル名に置き換えてから実行してください。

```sql
-- 1. テーブルを別名にする
exec sp_rename 'TARGETTABLE', 'TARGETTABLE_BACKUP';
exec sp_rename 'pk_TARGETTABLE', 'pk_TARGETTABLE_BACKUP';

go

-- 2. 新テーブルを作成する
create table TARGETTABLE (
    列名1  varchar(10)  not null,
    列名2  varchar(20)  not null,
    :
    新規追加列  varchar(30)  not null,
    :
    列名N  varchar(40)  not null
)

go

-- 3. 旧テーブルから新テーブルに移行する（新規追加列は初期値をセットする）
insert into TARGETTABLE
select
  列名1,列名2,...,'',...,列名N
from
  TARGETTABLE_BACKUP

go

-- 4. 旧テーブルを削除する
drop table TARGETTABLE_BACKUP
```

以上です。
