---
layout:        post
title:         "[Ruby] 構造体を継承してコンストラクタをなくす"
date:          2018-06-23
category:      Ruby
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
---

構造体クラスである Struct を継承することで、コンストラクタを省略することができます。

以下の例では、「name」と「age」というフィールドを持つ構造体 Person を定義して、
それを Person クラスが継承しています。

```ruby
class Person < Struct.new('Person', 'name', 'age')
  def hello
    return "Hello! My name is #{self.name} and I'm #{self.age} years old"
  end
end

person = Person.new('Alice', 6)
puts person         # => #<struct Person name="Alice", age=6>
puts person.age     # => 6
puts person.hello() # => Hello! My name is Alice and I'm 6 years old.
```

Struct クラスのインスタンスもまたクラスなので、上のように継承することができます。
Rails使ったことある人ならマイグレーションファイルで

```ruby
class TableName < ActiveRecord::Migration[5.0]
```

と書かれてあるのを見たことがあると思いますが、これもまた配列から取得した要素がクラスであるので、動的に親クラスを決定していると言えます。

Struct を継承する場合の欠点は `self.name` のようにメソッド呼び出し（属性呼び出し; attr_accessor）の形式にしなければいけない点です。
大半の Rubyist はインスタンス変数として `@name` や `@age` のように使えることを望んでいると思うので、
これを使っている人はほとんど（少なくとも私の観測範囲では）いないと思います。

Pythonでやる場合も紹介しているので、
[構造体を継承してコンストラクタをなくす(Python)]({{ site.baseurl }}/python/class-namedtuple)
も参考までに。

以上です。
