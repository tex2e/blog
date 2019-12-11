---
layout:        post
title:         "OOP in Python"
date:          2016-12-03
category:      Python
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      false
published:     true
---

Python3におけるオブジェクト指向のまとめ

目次
-------

- [クラスの定義](#class)
- [コンストラクタ、フィールド、メソッド](#constructor)
- [クラスメソッド、クラス変数](#class-method)
- [スタティックメソッド](#static-method)
- [アクセス権](#access)
- [オーバーロード](#overload)
- [演算子の定義](#operator)
- [継承、オーバーライド](#extends)
- [関数デコレータ](#decorator)


<a name="class"></a>

クラスの定義
-----------

- `class` というキーワードでクラスを宣言
- `クラス名()` でインスタンスの生成

Python3

```python
class Spam:
    pass

spam = Spam()
```


<a name="constructor"></a>

コンストラクタ、フィールド、メソッド
------------------------------

- コンストラクタは `__init__` メソッドに定義する
- インスタンス変数の名前は `self.` から始まる
- インスタンス変数はデフォルトで public
- メソッドはデフォルトで public
- メソッドは必ず引数に `self` をとる

```python
class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def add(self, other) -> 'Point':
        return Point(self.x + other.x, self.y + other.y)

    def __str__(self):
        return "({}, {})".format(self.x, self.y)
```


<a name="class-method"></a>

クラスメソッド、クラス変数
------------------------------

- クラスメソッドを定義するには `@classmethod` の直下でメソッドを定義します
- クラスメソッドは、クラスからだけではなく、インスタンスからも呼び出すことが可能です
- クラス変数は、クラスのトップスコープで変数を宣言します
- クラス変数を参照する時は、`クラス名.クラス変数名`

```python
class User:
    # クラス変数
    user_count = 0

    # クラスメソッド
    @classmethod
    def get_user_count(klass):
        return klass.user_count

    def __init__(self):
        User.user_count += 1


User()
print(User.get_user_count())   # => 1
User()
User()
print(User().get_user_count()) # => 4
```


<a name="static-method"></a>

スタティックメソッド
------------------------------

クラスメソッドに良く似たものとして、スタティックメソッドがあります。
クラスメソッドとスタティックメソッドの違いは、「自身のクラスへの参照ができるかどうか」です。

- クラスメソッドは、クラス変数などを参照するときに使う
- スタティックメソッドは、クラス変数などを参照しないときに使う

```python
# 引数の数の違い

class A:
    @classmethod
    def class_method(klass, arg1, arg2):
        # クラス変数などを参照する場合は、classmethod を使う
        pass

    @staticmethod
    def static_method(arg1, arg2):
        # クラス変数などに依存しないメソッドは、staticmethod を使う
        pass
```

そのクラスの全てのメソッドをスタティックメソッドにすることで、
クラスをただの名前空間として扱うこともできます。

```python
class Math:
    @staticmethod
    def sqrt(x):
        """Returns the non-negative square root of x."""
        pass

    @staticmethod
    def pow(x, n):
        """Raises x to the power of n."""
        pass


Math.sqrt(4)
Math.pow(2, 10)
```


<a name="access"></a>

アクセス権
-----------

Pythonでは、変数の先頭などにアンダースコア「\_」をつけてカプセル化に近いことはできますが、
本当の意味でカプセル化することはできません。

Pythonには __ネームマングリング__（name mangling）というものがあり、
アンダースコア2つで始まるメンバを、外からアクセスする場合は次のようにアクセスする必要があります。
これによって private に近いことを実現しています。

```python
class Person:
    def __init__(self, name):
        self.__variable = name

    def __method(self):
        return "Person's private method"


alice = Person("Alice")
print(alice._Person__method())
print(alice._Person__variable)
```

また、いろんな人のコードを見るとアンダースコアの数が1つと2つの場合（`_variable` と `__variable`）
がありますが、これらの使い分けの基準は次のような感じです。

- `_variable` は書き換えられたくない変数に用いる（読み取りはOK）
- `__variable` は読み書きされたくない変数に用いる



<a name="overload"></a>

オーバーロード
-------------

- Pythonではオーバーロードはできないが、デフォルト引数を取ることはできる

```python
class A
    def method(self, a, b=None):
        if b is None:
            # ...
            pass
        else
            # ...
            pass
```


<a name="operator"></a>

演算子の定義
-----------------------

Pythonで定義できる演算子一覧

演算子に対応するメソッドは `__***__` の形式になります。
累積代入文に対応するメソッドは `__i***__` の形式になります。

| 演算子          | 対応メソッド                     | 演算子          | 対応メソッド     |
| :------------- | :----------------------------- | :------------- | :------------- |
| +              | \_\_add\_\_(self, other)       | +=             | \_\_iadd\_\_(self, other)
| -              | \_\_sub\_\_(self, other)       | -=             | \_\_isub\_\_(self, other)
| *              | \_\_mul\_\_(self, other)       | *=             | \_\_imul\_\_(self, other)
| /              | \_\_truediv\_\_(self, other)   | /=             | \_\_itruediv\_\_(self, other)
| //             | \_\_floordiv\_\_(self, other)  | //=            | \_\_ifloordiv\_\_(self, other)
| %              | \_\_mod\_\_(self, other)       | %=             | \_\_imod\_\_(self, other)
| **             | \_\_pow\_\_(self, other)       | **=            | \_\_ipow\_\_(self, other)
| <<             | \_\_lshift\_\_(self, other)    | <<=            | \_\_ilshift\_\_(self, other)
| >>             | \_\_rshift\_\_(self, other)    | >>=            | \_\_irshift\_\_(self, other)
| &              | \_\_and\_\_(self, other)       | &=             | \_\_iand\_\_(self, other)
| ^              | \_\_xor\_\_(self, other)       | ^=             | \_\_ixor\_\_(self, other)
| ｜             | \_\_or\_\_(self, other)        | ｜=            | \_\_ior\_\_(self, other)


演算子の左辺が演算子を定義していない場合は、演算子の右辺の `__r***__` メソッドが呼び出されます。

`__radd__`, `__rsub__`, `__rmul__`, ...（省略）

単項演算子に対応するメソッドは次の通りです。

| 演算子          | 対応メソッド     |
| :------------- | :------------- |
| +（単項演算子）  | \_\_pos\_\_(self)
| -（単項演算子）  | \_\_neg\_\_(self)
| ^（単項演算子）  | \_\_invert\_\_(self)


<a name="extends"></a>

継承、オーバーライド
------------------

- 継承は `class Sub(Super):`
- 多重継承は `class Sub(Super1, Super2, ...)` とすることで可能（メソッド探索は必ずしも幅優先探索になるとは限らない）
- 同名のメソッドを定義すれば、オーバーライドになる
- 親クラスを呼び出すときは `super()` を使う

```python
class Super:
    def foo(self):
        print("Super's method foo()")

class Sub(Super):
    def foo(self):
        print("Sub's method foo()")
        super().foo()


sub = Sub()
sub.foo()
# => "Sub's method foo()"
# => "Super's method foo()"
```

<div class="tip">
Python2で親クラスのメソッドのオーバーライドは、親クラスが object クラスを継承していないとできません。
Python3では全てのクラスが object クラスを継承しているため、この問題は起こりません。
</div>


<a name="decorator"></a>

関数デコレータ
------------------

関数の宣言の前に `@` から始まる関数名を書くことができます。これを __関数デコレータ__ といいます。
`@staticmethod` や `@classmethod` も関数デコレータの一つです。

```python
class Spam:
    @staticmethod
    def method(arg):
        pass
```

上のコードは、下のコードと同じ意味を持ちます。

```python
class Spam:
    def method(arg):
        pass

    method = staticmethod(method)
```

関数デコレータは複数設定することもできます。

```python
@A
@B
@C
def f(arg):
    pass
```

上のコードは、下のコードと同じ意味を持ちます。

```python
def f(arg):
    pass

f = A(B(C(f)))
```

### 関数デコレータの定義

関数デコレータはクラスとして定義します。

- `__init__` では受け取る関数をインスタンス変数にセットします
- `__call__` では呼び出されたときに行うデコレート処理を書きます

```python
class html_p_tag:
    def __init__(self, func):
        self.func = func

    def __call__(self, *args):
        return "<p>" + self.func(*args) + "</p>"


# 関数デコレータの適用
@html_p_tag
def content(text):
    return text

print(content("hello, world!"))
# => "<p>hello, world!</p>"
```

関数も呼び出し可能（Callable）なオブジェクトなので、関数を使って関数デコレータを作ることも可能です。

```python
def html_p_tag(f):
    def new_func(*args):
        return "<p>" + f(*args) + "</p>"
    return new_func


# 関数デコレータの適用
@html_p_tag
def content(text):
    return text

print(content("hello, world!"))
# => "<p>hello, world!</p>"
```

__部分適用__ を行うことで、関数デコレータに引数を渡すこともできます。

- `__init__` では受け取る引数をインスタンス変数にセットします
- `__call__` では `__init__` で受け取った引数を元に新しい関数を返します。その新しい関数の中にデコレート処理を書きます

```python
class html_tag:
    def __init__(self, tag_name):
        self.tag_name = tag_name

    def __call__(self, func):
        def new_func(*args):
            return "<{0}>{1}</{0}>".format(self.tag_name, func(*args))
        return new_func


# 関数デコレータの適用
@html_tag("div")
@html_tag("p")
def content(text):
    return text

print(content("hello, world!"))
# => "<div><p>hello, world!</p></div>"
```
