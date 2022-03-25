---
layout:        post
title:         "MySQLで1〜Nの数列を扱う"
date:          2019-03-10
category:      Database
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex: true
---

MySQL で1〜Nの数列を作る方法について説明します。

SQL は SELECT クエリを使うと、その結果がテーブルの形式で返ってきます。
一般的に SELECT は FROM SELECT だけでも結果が返ってきます。
つまり `select 1;` は値が1のレコードが得られます。
そしたら UNION を使ってレコードを結合していきます。
UNION は何回でも使えるので、これを繋げていけば任意の数までの数列ができますが、効率が悪いです。

```sql
MariaDB [(none)]> select 1 union select 2 union select 3;
+---+
| 1 |
+---+
| 1 |
| 2 |
| 3 |
+---+
3 rows in set (0.00 sec)
```

次に直積を使うことを考えます。
直積は JOIN もしくは CROSS JOIN ですが、FROM のところだと単にカンマ「,」で並べるだけで、直積が得られます。
下の例は直積 $$ \{0,1\} \times \{0,1\} \times \{0,1\} $$ の例です。
これは3桁の2進数になるので、上手に扱えば任意の数列になるかもしれません（ただし今回は2進数から数列を作る話ではないです）。

```sql
MariaDB [(none)]> select * from (select 0 union select 1) t1,
                                (select 0 union select 1) t2,
                                (select 0 union select 1) t3;
+---+---+---+
| 0 | 0 | 0 |
+---+---+---+
| 0 | 0 | 0 |
| 1 | 0 | 0 |
| 0 | 1 | 0 |
| 1 | 1 | 0 |
| 0 | 0 | 1 |
| 1 | 0 | 1 |
| 0 | 1 | 1 |
| 1 | 1 | 1 |
+---+---+---+
8 rows in set (0.00 sec)
```

次に、MySQL ではユーザ変数を定義できるので、レコード毎にインクリメントした値を使うことができれば数列 0,1,2,3,... を作ることができます。

```sql
MariaDB [(none)]> set @num := 0;
MariaDB [(none)]> select @num := @num+1 n from (select 0 union select 1) t1,
                                               (select 0 union select 1) t2,
                                               (select 0 union select 1) t3;
+------+
| n    |
+------+
|    1 |
|    2 |
|    3 |
|    4 |
|    5 |
|    6 |
|    7 |
|    8 |
+------+
8 rows in set (0.00 sec)
```

あとは、limit で数列の最大値を決めてあげれば、任意の数列を作ることができます。

例えば、1,2,...,100 の数列を作る場合は次のようになります（4×4×4×4 = 256 で最大を 100 にしています）。
ただしワンライナーで書いている関係で FROM のところに違和感があるかもしれませんが、
`select @num := 0` は空集合を返すので直積には影響しません。

```sql
select @num := @num+1 n
from (select @num := 0) t0,
  (select 1 union select 2 union select 3 union select 4) t1,
  (select 1 union select 2 union select 3 union select 4) t2,
  (select 1 union select 2 union select 3 union select 4) t3,
  (select 1 union select 2 union select 3 union select 4) t4
  limit 100;
```

出力は次のようになり、1〜100の数列が作られていることが確認できます。

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
