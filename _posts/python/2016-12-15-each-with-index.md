---
layout:        post
title:         "[Python] RubyのEnumerable#each_with_indexを自作する"
date:          2016-12-15
category:      Python
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from:
comments:      false
published:     true
---

Python で Ruby の Enumerable#each_with_index を行う方法について説明します。


組み込み関数 enumerate を使う
--------------------

配列をループで順番にアクセスするときに、そのインデックスも使いたいときがあります。

```python
members = ['Alice', 'Carol', 'Bob', 'Dave']

i = 0
for member in members:
    print("{}: {}".format(i, member))
    i += 1

```

インデックスをカウントするために変数 i を定義する方法もありますが、
代わりに、enumerate という組み込み関数を使って、変数 i のスコープを小さくすることができます。

```python
members = ['Alice', 'Carol', 'Bob', 'Dave']

for i, member in enumerate(members):
    print("{}: {}".format(i, member))

```


### 余談

enumerate はジェネレータ関数であり、次のコードと等価です。

```python
def enumerate(sequence, start=0):
    n = start
    for elem in sequence:
        yield n, elem
        n += 1
```

以上です。


See Also
--------------------

[Python3 library functions enumerate](http://docs.python.jp/3/library/functions.html#enumerate)
