---
layout:        post
title:         "[SQLServer] SELECTした行に連番を振る (ROW_NUMBER)"
date:          2024-06-03
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

SQLServerでSELECTした行に連番を振る（採番する）には、組み込み関数の ROW_NUMBER() を利用することで実現することができます。
さらに、ROW_NUBMER の PARTITION BY を使うことで、採番するときに特定のキーが変わったタイミングで1から振り直すこともできます。

```sql
SELECT
    emp_id,
    first_name,
    last_name,
    dep_id,
    ROW_NUMBER() OVER (
        PARTITION BY
            dep_id
        ORDER BY
            emp_id
    ) AS row_number
FROM
    employee
ORDER BY
    emp_id
```

実行結果（dep_id グループごとの採番結果は row_number 列を参照）

```output
emp_id  first_name  last_name  dep_id  row_number
------- ----------- ---------- ------- -----------
     11 Diane       Wood       hr                1
     12 Bob         Yakamoto   hr                2
     21 Emma        Verde      it                1
     22 Grace       Tanner     it                2
     23 Henry       Sivers     it                3
     24 Irene       Romen      it                4
     25 Frank       Utrecht    it                5
     31 Cindy       Xerst      sales             1
     32 Dave        Walsh      sales             2
     33 Alice       Zakas      sales             3

(10 rows affected)
```

以上です。

### 参考資料

- [ROW_NUMBER (Transact-SQL) - SQL Server \| Microsoft Learn](https://learn.microsoft.com/ja-jp/sql/t-sql/functions/row-number-transact-sql?view=sql-server-ver16)

