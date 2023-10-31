---
layout:        post
title:         "Elixir Typespecs"
date:          2016-12-01
category:      Program
author:        tex2e
cover:         /assets/cover14.jpg
redirect_from: /elixir/types
comments:      false
published:     true
---

Elixir の型一覧
----------------

Atom, Boolean, String, Integer, Range, Float, List, Keyword List,
Map, Tuple, Function

- Atom
    - `:foo`
- Boolean
    - `true`
    - `false`
- String
    - `"foo"`
- Integer
    - `123`
- Range
    - `1..10`
- Float
    - `3.14`
- List
    - `[1, 2, 3]`
    - `[]`
- Keyword
    - `[key: "value"]`
- Map
    - `%{key: "value"}`
    - `%{3.14 => "π"}`
    - `%{}`
- Struct
    - `%SomeStruct{key: "value"}`
- Tuple
    - `{:ok, type}`
    - `{x, y, z} = {1, 2, 3}`
- [Binary](https://hexdocs.pm/elixir/Kernel.SpecialForms.html#%3C%3C%3E%3E/1)
    - `<<1, 2, 3>>`
    - `<<0, "foo"::utf8>>`
- [Bitstring](https://hexdocs.pm/elixir/Kernel.SpecialForms.html#%3C%3C%3E%3E/1)
    - `<<0, 1::size(7)>>`
- Function
    - `fn -> :ok end`
    - `fn ... -> :ok end`
    - `fn arg1, arg2 -> :ok end`
    - `&(&1)`
    - `&(&1 + &2)`
    - `&String.trim/1`
    - `&String.replace(&1, ~r/\s+/, "")`
