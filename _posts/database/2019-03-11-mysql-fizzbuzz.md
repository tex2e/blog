---
layout:        post
title:         "[MySQL] SQLでFizzBuzzを出力する"
date:          2019-03-11
category:      Database
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
---

まず FizzBuzz をするためには数列が必要ですが、1,2,...,100 の数列を作る場合は次のようになります（前回の [MySQLで1〜Nの数列を扱う](./mysql-numerical-sequence) を参照）。

```sql
select @num := @num+1 n
from (select @num := 0) t0,
  (select 1 union select 2 union select 3 union select 4) t1,
  (select 1 union select 2 union select 3 union select 4) t2,
  (select 1 union select 2 union select 3 union select 4) t3,
  (select 1 union select 2 union select 3 union select 4) t4
  limit 100;
```

出力は以下の通りです。

```
+------+
| n    |
+------+
|    1 |
|    2 |
|    3 |
|    4 |
|    5 |
...省略...
|   96 |
|   97 |
|   98 |
|   99 |
|  100 |
+------+
100 rows in set (0.00 sec)
```

これをサブクエリとして FizzBuzz の条件部分を CASE 文で実現するだけで FizzBuzz ができます。

```sql
select
  case
    when n % 15 = 0 then 'FizzBuzz'
    when n % 3 = 0 then 'Fizz'
    when n % 5 = 0 then 'Buzz'
    else n
  end n
from (
  select @num := @num+1 n
  from (select @num := 0) t0,
    (select 1 union select 2 union select 3 union select 4) t1,
    (select 1 union select 2 union select 3 union select 4) t2,
    (select 1 union select 2 union select 3 union select 4) t3,
    (select 1 union select 2 union select 3 union select 4) t4
    limit 100
) t;
```

出力は以下の通りです。

```
+----------+
| n        |
+----------+
| 1        |
| 2        |
| Fizz     |
| 4        |
| Buzz     |
| Fizz     |
| 7        |
| 8        |
| Fizz     |
| Buzz     |
| 11       |
| Fizz     |
| 13       |
| 14       |
| FizzBuzz |
| 16       |
| 17       |
| Fizz     |
| 19       |
| Buzz     |
| Fizz     |
| 22       |
| 23       |
| Fizz     |
| Buzz     |
| 26       |
| Fizz     |
| 28       |
| 29       |
| FizzBuzz |
| 31       |
| 32       |
| Fizz     |
| 34       |
| Buzz     |
| Fizz     |
| 37       |
| 38       |
| Fizz     |
| Buzz     |
| 41       |
| Fizz     |
| 43       |
| 44       |
| FizzBuzz |
| 46       |
| 47       |
| Fizz     |
| 49       |
| Buzz     |
| Fizz     |
| 52       |
| 53       |
| Fizz     |
| Buzz     |
| 56       |
| Fizz     |
| 58       |
| 59       |
| FizzBuzz |
| 61       |
| 62       |
| Fizz     |
| 64       |
| Buzz     |
| Fizz     |
| 67       |
| 68       |
| Fizz     |
| Buzz     |
| 71       |
| Fizz     |
| 73       |
| 74       |
| FizzBuzz |
| 76       |
| 77       |
| Fizz     |
| 79       |
| Buzz     |
| Fizz     |
| 82       |
| 83       |
| Fizz     |
| Buzz     |
| 86       |
| Fizz     |
| 88       |
| 89       |
| FizzBuzz |
| 91       |
| 92       |
| Fizz     |
| 94       |
| Buzz     |
| Fizz     |
| 97       |
| 98       |
| Fizz     |
| Buzz     |
+----------+
100 rows in set (0.00 sec)
```

以上です。
