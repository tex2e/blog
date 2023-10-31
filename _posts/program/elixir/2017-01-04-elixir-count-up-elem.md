---
layout:        post
title:         "Elixirで配列の要素数をカウントする"
date:          2017-01-04
category:      Program
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from: /elixir/count-up-elem
comments:      false
published:     true
---

Elixirで配列の要素数をカウントする方法について、単語の出現回数を数える例を使って説明します。

目標
-----------

例えば、下のような文字列の配列があるとき、

```elixir
words = [
  "And", "on", "the", "seventh", "day", "God", "finished", "the", "work",
  "that", "he", "had", "done", ",", "and", "he", "rested", "on", "the",
  "seventh", "day", "from", "all", "the", "work", "that", "he", "had",
  "done", "."]
```

その要素（単語）の出現回数をカウントしたいとします。
期待する出力は Map で、key はその要素、value は出現回数とします。

```elixir
result = %{
  "," => 1, "." => 1, "And" => 1, "God" => 1, "all" => 1, "and" => 1,
  "day" => 2, "done" => 2, "finished" => 1, "from" => 1, "had" => 2, "he" => 3,
  "on" => 2, "rested" => 1, "seventh" => 2, "that" => 2, "the" => 4,
  "work" => 2}
```

解決方法
-----------

はじめに結論を言うと、次のコードを使えば良いです。

```elixir
Enum.reduce(list, %{}, fn x, acc -> Map.update(acc, x, 1, &(&1 + 1)) end)
```

#### `Enum.reduce(enumerable, acc, fun)`

まず、Enum.reduce を使って一つのオブジェクトにまとめていきます。
Map にまとめていきたいので、`acc` の初期値は %{} もしくは Map.new とします。

次に、`fun` には、1つのオブジェクトにまとめる方法を書きます。
`fun` には各要素と `acc` (初期値は Map.new) がパラメータとして渡されるので、ここでは Map.update を使って `acc` を更新していきます。

#### `Map.update(map, key, initial, fun)`

Map.update は渡された `map` の `key` に `initial` を代入しますが、すでに値が入っていた場合には `fun` を実行してその返り値を代入する関数です。

上のコードの場合だと、`map` に未登録の単語があれば 1 で初期化し、すでに単語が存在すれば `&(&1 + 1)` をします。
つまり、現在の値に 1 を加えます。


結論
-----------

最終的に単語を数えるコードは次のようになります。

```elixir
words |> Enum.reduce(%{}, fn word, acc -> Map.update(acc, word, 1, &(&1 + 1)) end)
```
