---
layout:        post
title:         "OOP in Elixir"
menutitle:     "OOP in Elixir"
date:          2016-12-03
tags:          Programming Language Elixir OOP
category:      Elixir
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      false
published:     true
---

Elixirにおけるオブジェクト指向のまとめ

目次
-------

- [クラスの定義](#class)
- [コンストラクタ、フィールド、メソッド](#constructor)
- [クラスメソッド、クラス変数](#class-method)
- [アクセス権](#access)
- [オーバーロード](#overload)
- [継承](#extends)
- [インターフェース](#interface)
- [プロトコル](#protocol)


この文章は筆者が Ruby のコードを Elixir に書き落とすために書いたものなので、
関数型特有の言い回しがあるのにそれを使わないでオブジェクト指向の語句を使っている場合が多々あります。
ご了承ください。


<a name="class"></a>

クラスの定義（Struct）
---------------------

何度も繰り返すと思いますが、Elixir にはクラスはないです。
代わりに、Elixir の構造体を使います。

- `defmodule` でモジュールの宣言
- モジュールの宣言の内の `defstruct` で構造体の宣言

```elixir
defmodule User do
  defstruct [:name, :age]
end


defmodule Main do
  require User
  alice = %User{name: "Alice", age: 20}
  IO.inspect alice.name # => "Alice"
end
```


<a name="constructor"></a>

コンストラクタ、フィールド、メソッド
------------------------------

- コンストラクタはありません。
  構造体は、Key の名前が事前に指定されている Map と同じだからです。
- フィールドは `defstruct` を使って定義します。
- フィールド名だけを宣言するには `defstruct` に名前を表す Atom の配列を渡します。
  例：`defstruct [:x, :y]`
- フィールド名の宣言と一緒に初期値を設定する場合は、`defstruct` にハッシュでパラメータを渡します。
  例：`defstruct x: 0, y: 0`
- インスタンスメソッドを定義することはできませんので、代わりにクラスメソッドを定義します
  （Elixir の Module で行う `def` を使った普通の関数定義）。

```elixir
defmodule Point do
  defstruct x: 0, y: 0

  def add(%Point{x: x, y: y}, %Point{x: other_x, y: other_y}) do
    %Point{x: x + other_x, y: y + other_y}
  end
end


defmodule Main do
  require Point
  p1 = %Point{x: 3, y: 4}
  p2 = %Point{x: -2, y: 2}
  IO.inspect Point.add(p1, p2) # => %Point{x: 1, y: 6}
end
```


関数の引数でのマップのキーとマップ全体をそれぞれバインドする方法（補足）
-------------------------------------

関数の引数でのマップのキーとマップ全体をそれぞれバインドするには
`= variable`を使います。

```
def check_data(%Point{x: x, y: y} = point) do
  # access x, y, point
end
```


<a name="update-syntax"></a>

アップデート構文（update syntax）（補足）
-------------------------------------

構造体は、ほとんど Map と同じなので、Map のアップデート構文を使うことができます。

```elixir
defmodule Point do
  defstruct x: 0, y: 0
end


defmodule Main do
  require Point
  p1 = %Point{x: 3, y: 4}
  p2 = %Point{p1 | y: 7}
  IO.inspect p2 # => %Point{x: 3, y: 7}
end
```


<a name="class-method"></a>

クラスメソッド、クラス変数
------------------------------

module で定義した関数は全てクラスメソッドです

```elixir
defmodule Math do
  def sqrt(x) do
    :math.sqrt(x)
  end

  def pow(x, e) do
    :math.pow(x, e)
  end
end

IO.inspect Math.sqrt(3) # => 1.7320508075688772
IO.inspect Math.pow(2, 10) # => 1024.0
```

「クラス変数」は Agent や GenServer のようなステートを保持する機構でこれを実装するのが好ましいと思われます。

```elixir
defmodule User do
  defstruct [:name, :age]

  def new(name: name, age: age) do
    increment_user_count
    %User{name: name, age: age}
  end

  # --- Agent ---

  def start_link do
    Agent.start_link(fn -> 0 end, name: __MODULE__)
  end

  def get_user_count do
    Agent.get(__MODULE__, fn count -> count end)
  end

  defp increment_user_count do
    Agent.update(__MODULE__, fn count -> count + 1 end)
  end
end


User.start_link
IO.inspect User.get_user_count  # => 0

_user1 = User.new(name: "Alice", age: 20)
_user2 = User.new(name: "Bob", age: 22)

IO.inspect User.get_user_count  # => 2
```


<a name="access"></a>

アクセス権
-----------

- モジュールのメソッドは public と private の2種類があります。
- `def` で宣言されたメソッドは public
- `defp` で宣言されたメソッドは private

```elixir
defmodule Sample do
  def public_function do
    # ...
  end

  defp private_function do
    # ...
  end
end
```


<a name="overload"></a>

オーバーロード
-------------

Elixirではパターンマッチ（オーバーロード）ができます

```elixir
defmodule PatternMatch do
  def call(x) when is_number(x) do
    x + 123
  end

  def call(x) when is_list(x) do
    [123 | x]
  end

  def call(x) when is_function(x) do
    x.(123)
  end
end

IO.inspect PatternMatch.call(1)   # => 124
IO.inspect PatternMatch.call([1]) # => [123, 1]
IO.inspect PatternMatch.call(fn a -> a * 2 end) # =>  246
```

デフォルト引数を取ることもできます

```elixir
defmodule Concat do
  def join(a, b, sep \\ " ") do
    a <> sep <> b
  end
end

IO.puts Concat.join("Hello", "world")      #=> Hello world
IO.puts Concat.join("Hello", "world", "_") #=> Hello_world
```


<a name="extends"></a>

継承
----------

Elixirは関数型言語なのでクラスはありません。つまり継承もありません。
Elixirのモジュールや構造体も同じように継承という考え方はありません。


<a name="interface"></a>

インターフェース
-----------------

Javaでいう「インターフェース」に近いものがElixirにはあります。
__ビヘイビア__ （__Behaviours__） です。

ビヘイビアはモジュールの宣言と同じように宣言しますが、
抽象メソッドや抽象マクロを定義する時は `@callback` と `@macrocallback` を使います。
これらのモジュール属性の値には
[Typespecs](http://elixir-lang.org/docs/stable/elixir/typespecs.html)
を使用します。

```elixir
defmodule MyBehaviour do
  @callback my_fun(arg :: any) :: any
  @macrocallback my_macro(arg :: any) :: Macro.t

  # @optional_callbacks を使うことで、そのcallbackの実装を強制しないようになる
  # 引数は {関数orマクロ名, 引数} のリスト
  @optional_callbacks my_fun: 0, my_macro: 1
end
```

ビヘイビアの実装は、実装するモジュール側で `@behaviour モジュール名` と記述します。

```elixir
defmodule MyBehaviour do
  @callback my_fun(arg :: any) :: any
end

defmodule MyCallbackModule do
  @behaviour MyBehaviour
  def my_fun(arg), do: arg
end
```


<a name="protocol"></a>

プロトコル
-----------------

ビヘイビア（Java で言うところの Interface）は先に抽象メソッドを定義するのに対して、
__プロトコル__（__Protocol__）は後からその型（ユーザ定義も含む）に対応する関数を書く方法です。

具体的な組み込みプロトコルの例としては、Enumerable や String.Chars などがあります。
なお、Enumerable を実装していると Enum の関数が、
String.Chars を実装していると to_string が使えるようになります。

Elixirではfalseとnilだけがfalseとして扱われ、他の全てはtrueと評価されます。
ここでは、オブジェクトがブランクなとき（空文字、空リストなど）に true を返すような blank? プロトコルを規定する例を示します。

```elixir
# プロトコルの定義
defprotocol Blank do
  @fallback_to_any true  # これを宣言すると、Anyに対する実装（impl）が行えるようになる
  def blank?(data)
end

# 全てのデータ型に対するデフォルトの実装
defimpl Blank, for: Any do
  def blank?(_),  do: false
end

# Listに対するBlankプロトコルの実装
defimpl Blank, for: List do
  def blank?([]), do: true
  def blank?(_),  do: false
end

# Atomに対するBlankプロトコルの実装
defimpl Blank, for: Atom do
  def blank?(false), do: true
  def blank?(nil),   do: true
  def blank?(_),     do: false
end

# Stringに対するBlankプロトコルの実装
defimpl Blank, for: BitString do
  def blank?(str), do: String.length(str) == 0
end

IO.inspect Blank.blank?([])  # => true
IO.inspect Blank.blank?(nil) # => true
IO.inspect Blank.blank?("")  # => true
IO.inspect Blank.blank?(0)   # => false （Integerに対してはBlankを実装していない）
```

実装が可能な組み込みデータ型は、次の通りです。

- Atom
- BitString（文字列型）
- Float
- Function
- Integer
- List
- Map
- PID
- Port
- Reference
- Tuple

また、プロトコルの実装は組み込みデータ型の他に、ユーザの定義した構造体に対しても実装することができます。
