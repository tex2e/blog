---
layout:        post
title:         "[SQLServer] 全ての接続元セッションを切断するためのSQL"
date:          2024-08-03
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
- [../database/sqlserver-disconnect-connection-table, "[SQLServer] テーブルをロックしているセッションを特定するSQL"]
---

ここでは、SQL Server で特定の**データベース**に接続している全ての接続元セッションを切断する方法について説明します。

例えば、DB名をリネームするときになどに、セッションが存在すると、DBに対する操作が失敗してしまいます。
そこで、以下のSQLを使用して全てのセッションを特定し、特定したセッションを終了 (kill) させる必要があります。

```sql
SELECT [dm_exec_sessions].[session_id]
FROM   [sys].[dm_exec_sessions]
       INNER JOIN [sys].[dm_exec_connections]
               ON [dm_exec_sessions].[session_id] =
                  [dm_exec_connections].[session_id]
       INNER JOIN [sys].[databases]
               ON [dm_exec_sessions].[database_id] = [databases].[database_id]
WHERE  [databases].[name] = 'データベース名' -- ここに接続を切りたいデータベース名を記述する


kill セッションID;  -- 上記のSQLで特定したセッションを終了する
```

以上です。


### 参考資料

- [T-SQLで特定DBへの接続をすべて切断する - ねこさんのぶろぐ](https://www.neko3cs.net/entry/how-to-disconnect-sql-server-db-connection)
