---
layout:        post
title:         "[Elixir] FizzBuzzを作成する"
type:          How-To
description:   "Elixirのfor内包表記とEnum.mapをそれぞれ使い、パイプ演算子と組み合わせてFizzBuzzを実装する方法を紹介します。"
tags:          [programming, elixir, fizzbuzz]
status:        stable
stale_after:   2027-10-13T00:00:00Z
generated:
  by:          human:tex2e
  at:          2017-01-04T09:56:47Z
date:          2017-01-04
category:      Programming
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from:
    - /elixir/fizzbuzz
    - /program/elixir-fizzbuzz
comments:      false
published:     true
---


for 文による FizzBuzz
--------------------

Elixir の for 文は do の内容の返り値をまとめてリストとして返します。
つまり、for 〜 end の後にパイプ演算子を繋げば、そのまま処理を続けることができます。

```elixir
for n <- 1..20 do
  cond do
    rem(n, 3) == 0 and rem(n, 5) == 0 -> "FizzBuzz"
    rem(n, 3) == 0 -> "Fizz"
    rem(n, 5) == 0 -> "Buzz"
    true -> n
  end
end
|> IO.inspect
# => [1, 2, "Fizz", 4, "Buzz", "Fizz", 7, 8, "Fizz", "Buzz",
#     11, "Fizz", 13, 14, "FizzBuzz", 16, 17, "Fizz", 19, "Buzz"]
```


Enum.map による FizzBuzz
-----------------------

FizzBuzz 処理の入力もパイプとして流し込めるようにしたい場合は、
次のように Range オブジェクトを Enum.map に流し込みます。

```elixir
1..20
|> Enum.map(fn n ->
    cond do
      rem(n, 3) == 0 and rem(n, 5) == 0 -> "FizzBuzz"
      rem(n, 3) == 0 -> "Fizz"
      rem(n, 5) == 0 -> "Buzz"
      true -> n
    end
  end)
|> IO.inspect
# => [1, 2, "Fizz", 4, "Buzz", "Fizz", 7, 8, "Fizz", "Buzz",
#     11, "Fizz", 13, 14, "FizzBuzz", 16, 17, "Fizz", 19, "Buzz"]
```

以上です。
