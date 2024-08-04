---
layout:        post
title:         "[SQLServer] テーブルをロックしているセッションを特定するSQL"
date:          2024-08-04
category:      Database
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
similarPosts:
- [../database/sqlserver-disconnect-connection-db, "[SQLServer] 全ての接続元セッションを切断するためのSQL"]
---

ここでは、SQL Server で特定の**テーブル**をロックしている全ての接続元セッションを切断する方法について説明します。

SQL Server と接続しているとき、デッドロックなどの何らかの理由でテーブルにロックをかけたまま解放しない事象が発生することがあります。
そのときは、以下のSQLでロックしているセッションを特定し、そのテーブルをロックしているセッションを終了 (kill) させる必要があります。

```sql
SELECT Object_name(t2.object_id) AS tableName,
       resource_type             AS type,
       request_session_id        AS sessionId
FROM   sys.dm_tran_locks t1
       INNER JOIN sys.partitions t2
               ON t1.resource_associated_entity_id = t2.hobt_id
WHERE  Object_name(t2.object_id) = 'テーブル名'; -- ここに接続を切りたいテーブル名を記述する


kill セッションID;  -- 上記のSQLで特定したセッションを終了する
```

以上です。
