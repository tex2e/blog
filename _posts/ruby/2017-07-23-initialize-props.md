---
layout:        post
title:         "[Ruby] インスタンス変数の初期化をメタプロする"
menutitle:     "[Ruby] インスタンス変数の初期化をメタプロする"
date:          2017-07-23
tags:          Programming Language Ruby
category:      Ruby
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
---

Rubyクラスのコンストラクタでインスタンス変数の初期化をしたいときは、以下のように書くのが一般的である。

```ruby
class Foo
  attr_accessor :foo1, :foo2, :foo3
  def initialize(foo1, foo2, foo3)
    self.foo1 = foo1
    self.foo2 = foo2
    self.foo3 = foo3
  end
end

foo = Foo.new(123, 'abc', true)
```

しかし、インスタンス変数が複数個あれば、その全ての変数名を引数として受け取らないといけないし、
インスタンス変数への代入も単純な作業ではあるが逐一記述するのも大変である。

一方、以下のように引数をhashにしてメタプログラミングで初期化していく技もある。

```ruby
class Foo
  attr_accessor :foo1, :foo2, :foo3
  def initialize(**params)
    params.each { |k, v| self.send("#{k}=", v) if self.methods.include?(k) }
  end
end

foo = Foo.new(foo1: 123, foo2: 'abc', foo3: true)
```

受け取った引数を key-value のペアで一つずつ見ていき、
keyの名前に `=` を付け加えた関数名に、valueを与えて呼び出している。
なお、Object#send は第一引数に関数名（文字列）を与えるとその関数を呼び出すことができる。
また、attr_accessor は与えられた名前のゲッターとセッターを生成する。

```ruby
# 展開前
attr_accessor :foo

# 展開後
def foo
  @foo
end
def foo=(val)
  @foo = val
end
```

したがって、インスタンス変数の値の読み書きは実際には関数が行うので、
動的な関数呼び出しができる Object#send を利用する。
