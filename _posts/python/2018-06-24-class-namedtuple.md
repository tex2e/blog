---
layout:        post
title:         "[Python] 構造体を継承してコンストラクタをなくす"
date:          2018-06-24
category:      Python
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
---

[[Ruby] 構造体を継承してコンストラクタをなくす]({{ site.baseurl }}/ruby/class-struct)
の続き。

python3 には collections.namedtuple という構造体のような振る舞いをするクラスがあります。

以下の例では、「name」と「age」というフィールドを持つ構造体 Person を定義して、それを Person クラスが継承しています。

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

namedtuple クラスのインスタンスもまたクラスなので、上のように継承することができます。
python で単純に制約のないフィールドを定義したい場合は、namedtuple を使うのをおすすめします。

以上です。
