---
layout:        post
title:         "配列を返すメソッドをブロックも受け付けるように拡張する"
date:          2016-12-08
category:      Ruby
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
---

Rubyで配列を返すメソッドをブロックも受け付けるように拡張する方法について説明します。


問題
----------

ここでは問題の単純化の為に、例としてソートした配列を返すメソッド sort_array というのがあるとする。

```ruby
def sort_array(array)
  array.sort
end
```

このとき、

```ruby
members = ['Alice', 'Carol', 'Bob', 'Dave']

sorted = sort_array(members)
# => ['Alice', 'Carol', 'Bob', 'Dave']
```

と書けば配列を返すメソッドとなるが、ブロック（do ~ end）が渡されるとまるで Enumerator のように
中身を一つずつ引数に渡すような関数を作りたいとする。

```ruby
sort_array(members) do |elem|
  puts elem
end
# >> Alice
# >> Carol
# >> Bob
# >> Dave
# => ['Alice', 'Carol', 'Bob', 'Dave']
```


block_given?, yield
--------------------

Ruby には Kernel#block_given? というメソッドがあり、関数にブロックが渡されると、true を返す。
yield というキーワードは、与えられたブロックに対して引数を渡す。

これらを使って、例の sort_array を再実装すると次のようになる。

```ruby
def sort_array(array)
  array.sort.tap do |sorted|
    sorted.each { |elem| yield elem } if block_given?
  end
end
```

Object#tap は、ブロックに自分自身（self）を渡し、自分自身を返す面白いメソッドである。
もし、Object#tap を使わないでこれを書く場合は、次のように書く。

```ruby
def sort_array(array)
  sorted = array.sort
  sorted.each { |elem| yield elem } if block_given?
  sorted
end
```

Object#tap を使った方が、変数のスコープが小さくなるというメリットがある（この例の場合では sorted という変数）。
しかし、ネストが増えるというデメリットもある。今回はネストが深いわけではないので、積極的に Object#tap
を使っていくこととする。


&block
-------------

加えてさらに、改善できる点がある。
`.each { |elem| yield elem }` というコードは、each から渡された要素を、
sort_array 関数が受け取ったブロックに流しているだけである。
ブロック（block）からプロック（Proc）への変換は単項演算子 `&` を使えばいいという点と、
each のような Enumerable を扱うメソッドは、引数としてプロック（Proc）を受け取れることを考慮すれば、
sort_array 関数のブロックを each のプロックとして使えることがわかる。

```ruby
def sort_array(members, &block) # 明示的にブロックを引数としてとる
  members.sort.tap do |sorted|
    sorted.each(&block) if block
  end
end
```

まとめ
-------------

したがって、配列を返すメソッドをブロックも受け付けるように拡張するメソッドは最終的には次のように書けば良い。

```ruby
members = ['Alice', 'Carol', 'Bob', 'Dave']

def sort_array(array, &block)
  array.sort.tap do |sorted|
    sorted.each(&block) if block
  end
end

sorted = sort_array(members)
# => ['Alice', 'Carol', 'Bob', 'Dave']

sort_array(members) do |member|
  puts member
end
# >> Alice
# >> Carol
# >> Bob
# >> Dave
# => ['Alice', 'Carol', 'Bob', 'Dave']
```

以上です。
