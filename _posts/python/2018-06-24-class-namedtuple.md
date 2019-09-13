---
layout:        post
title:         "構造体を継承してコンストラクタをなくす(Python)"
menutitle:     "構造体を継承してコンストラクタをなくす(Python)"
date:          2018-06-24
tags:          Programming Language Python
category:      Python
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
---

[構造体を継承してコンストラクタをなくす(Ruby)]({{ site.baseurl }}/ruby/class-struct)
の続き．

python3 には collections.namedtuple という構造体のような振る舞いをするクラスがある．

下の例では，「name」と「age」というフィールドを持つ構造体 Person を定義して，
それを Person クラスが継承している．

```python
from collections import namedtuple

class Person(namedtuple('Person', ['name', 'age'])):
    def hello(self):
        return ("Hello! My name is {} and I'm {} years old." \
                .format(self.name, self.age))

person = Person("Alice", 6)
print(person)         # => Person(name='Alice', age=6)
print(person.age)     # => 6
print(person.hello()) # => Hello! My name is Alice and I'm 6 years old.
```

namedtuple クラスのインスタンスもまたクラスなので，上のように継承することができる．
python で単純に制約のないフィールドを定義したいならば，namedtuple を使うのをおすすめする．
