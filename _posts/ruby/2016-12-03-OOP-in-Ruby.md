---
layout:        post
title:         "[Ruby] オブジェクト指向プログラミング"
date:          2016-12-03
category:      Ruby
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from:
comments:      false
published:     true
---

Rubyにおけるオブジェクト指向のまとめ

目次
-------

- [クラスの定義](#class)
- [コンストラクタ、フィールド、メソッド](#constructor)
- [クラスメソッド、クラス変数](#class-method)
- [アクセス権](#access)
- [オーバーロード](#overload)
- [演算子の定義](#operator)
- [継承、オーバーライド](#extends)
- [モジュール](#module)
- [特異メソッドと特異クラス](#singleton-method-and-eigenclass)
- [リフレクションとメタプログラミング](#metaprogramming)
- [オープンクラス](#openclass)
- [リファインメント](#refinement)
- [動的メソッド生成](#definemethod)
- [フックメソッド](#hookmethod)


<a name="class"></a>

クラスの定義
-----------

- `class` というキーワードでクラスを宣言
- `クラス名.new` でインスタンスの生成

Ruby

```ruby
class Point
end

p = Point.new
```


<a name="constructor"></a>

コンストラクタ、フィールド、メソッド
------------------------------

- コンストラクタは `initialize` メソッドに定義する
- インスタンス変数の名前は `@` から始まる
- インスタンス変数はデフォルトで private
- メソッドはデフォルトで public

Pointクラスの例

```ruby
class Point
  # コンストラクタ（イニシャライザ）
  def initialize(x, y)
    @x, @y = x, y
  end

  def to_s
    "(#{@x}, #{@y})"
  end
end

p = Point.new(3, 5)
puts p.to_s
# => "(3, 5)"
```


<a name="class-method"></a>

クラスメソッド、クラス変数
------------------------------

- クラスメソッドは `def self.メソッド名` で定義する
- クラス変数は `@@クラス変数名` でアクセスする

```ruby
class User
  @@user_counter = 0

  def initialize
    @@user_counter += 1
  end

  def self.user_count
    @@user_counter
  end
end

puts User.user_count  # => 0
5.times { User.new }
puts User.user_count  # => 5
```


<a name="access"></a>

アクセス権
-----------

- インスタンス変数
    - デフォルトで private
    - `attr_reader :インスタンス変数名` で読み取りのみ可能になる
    - `attr_writer :インスタンス変数名` で書き込みのみ可能になる
    - `attr_accessor :インスタンス変数名` で読み書き可能になる
    - `attr_*` 系のメソッドの引数は可変長なので、まとめて指定することも可能
- メソッド
    - デフォルトで public
    - `private` メソッドを呼び出した後に定義したメソッドは全て private なメソッドになる
    - `protected` メソッドを呼び出した後に定義したメソッドは全て protected なメソッドになる

```ruby
class AccessModifiers
  attr_reader :x  # インスタンス変数 x は読み取りのみ可能
  attr_writer :y  # インスタンス変数 y は書き込みのみ可能
  attr_accessor :z  # インスタンス変数 z は読み書き可能

  def initialize(x, y, z)
    @x, @y, @z = x, y, z
  end

  def public_method
  end

  private
  def private_method
    # プライベートメソッド
  end

  def private_method2
    # プライベートメソッド
  end

  protected
  def protected_method
    # プロテクトメソッド
  end
end

sample = AccessModifiers.new(123, "foo", :bar)
puts sample.x  # => 123
sample.z = :baz
puts sample.z  # => :baz
```


<a name="overload"></a>

オーバーロード
-------------

- Rubyではオーバーロードはできないが、デフォルト引数を取ることはできる。

```ruby
class Point
  attr_reader :x, :y

  def initialize(x, y)
    @x, @y = x, y
  end

  def distance(other_point = nil)
    if other_point
      Math.sqrt(
        (self.x - other_point.x) ** 2 +
        (self.y - other_point.y) ** 2
      )
    else
      Math.sqrt(@x ** 2 + @y ** 2)
    end
  end
end

p1 = Point.new(3, 4)
p2 = Point.new(15, 20)
puts p1.distance     # => 5.0
puts p1.distance(p2) # => 20.0
```


<a name="self-vs-at"></a>

`self` vs `@` （補足）
---------------------

先の例のように、
インスタンス変数にアクセスするときには基本的に `@` を使うのだが、
そのインスタンス変数を `attr_reader` などに指定してある場合は、
プログラムの文脈によっては `self` からアクセスしたほうが英語として読み易い場合もある。

ただし、`self` から始める場合は、メソッド呼び出しとなるので、混乱しない程度に使おう。

```ruby
class Foo
  attr_reader :foo

  def initialize
    @foo = "instance var @foo"
  end

  def foo
    "public method foo()"
  end

  def get_foo
    puts self.foo
    # ここの self.foo はメソッドを呼んでいるのか、
    # それともインスタンス変数を参照しているのか、プログラムを動かすまでよく分からない
  end
end

sample = Foo.new
sample.get_foo  # => "public method foo()"
```

実際、`attr_*` 系のメソッドはメタプログラミングの一つで、動的に getter や setter を定義しているだけである。

```ruby
# attr_accessorの場合

class Foo
  attr_accessor :foo
end

# 上のコードは下のように展開される

class Foo
  # getter
  def foo
    @foo
  end

  # setter
  def foo=(value)
    @foo = value
  end
end
```


<a name="operator"></a>

演算子の定義
-------------

Rubyで定義できる演算子一覧（優先度順）

- `[]`, `[]=`
- `**`
- `!`, `~`, `+`, `-` （単項演算子を定義するときは `!@` のように `@` をくっつけること）
- `*`, `/`, `%`
- `+`, `-`
- `>>`, `<<`
- `&`
- `^`, `|`
- `<=`, `<`, `>`, `>=`
- `<=>`, `==`, `===`, `!=`, `=~`, `!~`

```ruby
class Point
  attr_reader :x, :y

  def initialize(x, y)
    @x, @y = x, y
  end

  def +(other)
    Point.new(self.x + other.x, self.y + other.y)
  end

  def -@
    Point.new(-@x, -@y)
  end

  def to_s
    "(#{@x}, #{@y})"
  end
end

puts Point.new(3, 5) + Point.new(-2, 5)
# => "(1, 10)"
puts -Point.new(3, 5)
# => "(-3, -5)"
```


<a name="extends"></a>

継承、オーバーライド
------------------

- 継承は `class A < B`
- 同名のメソッドを定義すれば、オーバーライドになる。

```ruby
class Point
  attr_reader :x, :y

  def initialize(x, y)
    @x, @y = x, y
  end

  def +(other)
    Point.new(self.x + other.x, self.y + other.y)
  end

  def to_s
    "(#{@x}, #{@y})"
  end
end

class Point3D < Point
  attr_reader :z

  def initialize(x, y, z)
    super(x, y)
    @z = z
  end

  def +(other)
    Point3D.new(self.x + other.x, self.y + other.y, self.z + other.z)
  end

  def to_s
    "(#{@x}, #{@y}, #{@z})"
  end
end

p1 = Point3D.new(1, 2, 3)
p2 = Point3D.new(4, 5, 6)
puts p1 + p2
# => "(5, 7, 9)"
```


<a name="module"></a>

モジュール
--------------------------

- `module` というキーワードでモジュールを宣言
- 使い方としては、名前空間としてのモジュールと、Mixin としてのモジュールの2種類ある

### 名前空間としてのモジュール

```ruby
module UTF8
  def self.encode(text)
    # ...
    text
  end

  def self.decode(text)
    # ...
    text
  end
end

text = UTF8.encode("123abc")
data = UTF8.decode(text)
```

モジュールの全てのメソッドを公開する場合は、全てのメソッドの前に `self.` をつける代わりに、
`module_function` を使うこともできる。

```ruby
module UTF8
  module_function

  def encode(text)
    # ...
    text
  end

  def decode(text)
    # ...
    text
  end
end

text = UTF8.encode("123abc")
data = UTF8.decode(text)
```

### Mixin としてのモジュール

```ruby
module SayGreeting
  def good_morning
    "good morning!"
  end

  def good_night
    "good night!"
  end
end

class Person
  include SayGreeting
end

alice = Person.new
puts alice.good_morning  # => "good morning!"
```


<a name="singleton-method-and-eigenclass"></a>

特異メソッドと特異クラス
------------------------

__特異メソッド__（Singleton Method）とは、あるオブジェクトにだけ所属するメソッドのことです。

```ruby
obj = "Alice"
other_obj = "Bob"

# objに対する、特異メソッドの定義
def obj.greet
  "My name is #{self}"
end

puts obj.greet       # => "My name is Alice"
puts other_obj.greet # => NoMethodError
```

上の例では、インスタンスに対して特異メソッドを定義しましたが、
クラス自身もオブジェクトなのでクラスにも特異メソッドを定義することができます。

ただし、クラスの特異メソッドは通常「クラスメソッド」などと呼ばれます。

```ruby
class A
  def initialize
    # ...
  end
end

# クラスAに対する、特異メソッドの定義
def A.method
  "A's class method"
end

puts A.method  # => "A's class method"
```

一般的に、クラスメソッドを定義するときは、次のようにクラスの宣言の内部で行います。

```ruby
class A
  # クラスオブジェクトを明示する場合
  def A.method
    "A's class method"
  end

  # selfというキーワードは、今いるスコープのクラスオブジェクトを返してくれる
  def self.method
    "A's class method"
  end

  def initialize
    # ...
  end
end
```

-------------------------------

__特異クラス__（Eigenclass）とは、そのオブジェクトだけが継承する無名のクラスのことです。
ちなみに、__特異メソッドは特異クラスのメソッドとして定義されます__。

Rubyにおいては、特異クラスは自分で定義できないので、
代わりに __特異クラスをオープンする__ といい、`class << obj` と書きます。

特異クラスをオープンすることによって、特異メソッドをまとめて定義することができます。

```ruby
obj = "Alice"
other_obj = "Bob"

# objの特異クラスをオープンし、特異メソッドを定義する
class << obj
  def greet
    "My name is #{self}"
  end

  def say_hello
    "Hello!"
  end
end

puts obj.greet       # => "My name is Alice"
puts other_obj.greet # => NoMethodError
```

上の例では、インスタンスに対して特異クラスをオープンしましたが、
クラス自身もオブジェクトなのでクラスの特異クラスもオープンすることができます。

同様に、クラスの特異クラスをオープンして、定義した特異メソッドは通常「クラスメソッド」などと呼びます。

```ruby
class A
  def initialize
    # ...
  end
end

# クラスAに対する、特異メソッドの定義
class << A
  def method
    "A's class method"
  end

  def method2
    "A's class method2"
  end
end

puts A.method  # => "A's class method"
```

一般的に、特異クラスをオープンしてクラスメソッドを定義するときは、次のようにクラスの宣言の内部で行います。

```ruby
class A
  class << self
    def method
      "A's class method"
    end

    def method2
      "A's class method2"
    end
  end

  def initialize
    # ...
  end
end

puts A.method   # => "A's class method"
puts A.method2  # => "A's class method2"
```

特異クラスの参照（補足）
--------------------------

この話は聞くと混乱するかもしれないので補足程度ですが、
特異クラスをオープンした中で self を使うことで、特異クラス自身を参照することができます。

```ruby
class A
  def A.eigenclass
    class << A
      self
    end
  end
end

puts A.eigenclass      # => #<Class:A>
puts A.eigenclass.name # =>（無名のクラスなので、クラス名はない）
```


<a name="metaprogramming"></a>

リフレクションとメタプログラミング
------------------------------

__リフレクション__ とは、プログラム自身が自分の状態や構造を解析することである。

Rubyにおいて __メタプログラミング__ とは、プログラムを動的に拡張することである。
具体的には、動的にメソッドを追加・変更・削除したり、動的にクラスを定義したりする。

リフレクションとメタプログラミングは非常に相性が良い。
処理の流れとしては、
リフレクションによってプログラム自身（クラスの継承関係など）を解析し、
その結果に基づいてメタプログラミング（動的にメソッドを追加するなど）を行う。

ここではリフレクションとメタプログラミングとメタプログラミングについて一から説明するつもりはないので、
クラス周辺にまつわるメタプログラミングについてだけ簡単に説明していく。


<a name="openclass"></a>

オープンクラス
------------------------------

- Rubyの全てのクラスは拡張可能である
- ただし安易に拡張することを __モンキーパッチ__ と呼び、
プログラム全体に影響がおよぶ可能性があるので、極力避けるべきである

```ruby
class String
  def to_alphanumeric
    self.gsub(/[^\w\s]+/, '')
  end
end

"abc 123 $%& edf".to_alphanumeric  # => "abc 123  edf"
```


<a name="refinement"></a>

リファインメント
------------------------------

__リファインメント__（Refinements）を使うと、オープンクラスの適用範囲を制限することができます。
モジュールで定義された拡張を有効にするには `using` キーワードを使います

```ruby
# リファインメントの定義
module StringExtender
  refine String do
    def to_alphanumeric
      self.gsub(/[^\w\s]+/, '')
    end
  end
end


class SandBox
  using StringExtender
  # => このスコープでのみ、Stringへの拡張メソッドが使えるようになる
end
```


<a name="definemethod"></a>

動的メソッド生成
------------------------------

- 動的にメソッドを定義するには Moduleクラスのプライベートメソッド
 `define_method` を使う

以下の例は、クラスマクロと動的メソッド生成の組み合わせ

```ruby
class Shop
  @@tax = 1.05

  def self.define_item(name, price)
    define_method(name) do
      "#{name} is ¥#{price * @@tax}"
    end
  end

  define_item("apple",  200)
  define_item("banana", 100)
  define_item("cherry", 300)
end

alice_shop = Shop.new
alice_shop.apple  # => "apple is ¥210.0"
alice_shop.banana # => "banana is ¥105.0"
```


<a name="hookmethod"></a>

フックメソッド
------------------------------

特定のイベントが発生したときに、自動で実行されるメソッドを __フックメソッド__ と呼ぶ

- 自クラスが継承されたときに呼ばれるメソッド `self.inherited`
- 自モジュールが Mixin されたときに呼ばれるメソッド `self.included`

```ruby
class A
  def self.inherited(subclass)
    puts "#{self} was extended by #{subclass}"
  end
end

class B < A
end
# => A was extended by B

class C < B
end
# => B was extended by C
```

```ruby
module A
  def self.included(subclass)
    puts "#{self} was included by #{subclass}"
  end
end

class B
  include A
end
# => A was included by B
```

Mixinしたときに、インスタンスメソッドとクラスメソッドの両方を取り込む技

- Mixinされるモジュールの `self.included` フックに
  Mixinする側のクラスの `extend` メソッドで、クラスメソッドを送り込む

```ruby
module A
  def self.included(subclass)
    subclass.extend(ClassMethods)
  end

  # クラスメソッドになるメソッドは、ClassMethodsに定義する
  module ClassMethods
    def class_method
      "this is class method."
    end
  end

  # インスタンスメソッドになるメソッドは、普通に定義する
  def instance_method
    "this is instance method."
  end
end


class B
  include A
end

B.class_method  # => "this is class method."
B.new.instance_method  # => "this is instance method."
```
