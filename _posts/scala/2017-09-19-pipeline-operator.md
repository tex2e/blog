---
layout:        post
title:         "Scalaでパイプライン演算子"
menutitle:     "Scalaでパイプライン演算子"
date:          2017-09-19
tags:          Programming Language Scala
category:      Scala
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
---

パイプライン演算子
----------------

パイプライン演算子 `|>` とは F# や Elixir などにある演算子で、
数学的にいうと、左辺の値を右辺の関数に適用する。すなわち、

```
# パイプライン演算子
123 |> fun
# 普通の書き方
fun(123)
```

ということである。


Scalaでパイプライン演算子の実装
-------------------------------

Scalaで演算子を使うには implicit 宣言を使う[^1]。
implicit によって既存のクラスに対する拡張を行うことができる。
パイプライン演算子 `|>` を定義するということは、任意のクラスに対してメソッド拡張を行うということなので[^2]、
型パラメータ（Javaで言う所のジェネリックス）を使って任意のクラスを T として定義する。

```scala
import scala.language.implicitConversions
import scala.language.reflectiveCalls

class PipelineHelper[T](x: T) {
  def |>[S](f: T => S): S = f(x)
}
implicit def Pipeline[T](x: T) = new PipelineHelper(x)

123 |> (_ * 2) |> println // => 246
```

このようにすることで、
任意の型 T のインスタンスに対してメソッド呼び出し「`|>`」が行われた時に、暗黙的に
PipelineHelper型に変換してから `|>` を呼び出す。

なお、ScalaのPredefには、implicitを使った定義がすでに存在する。
例えば、`1 to 3` と書くと、Scalaは暗黙的に1をint型からRichInt型に変換して、RichIntのメソッド to() を呼び出している。


ヘルバークラスの無名化
-----------------------

ヘルバークラス PipelineHelper は一回しか使われず、あえて名前をつけなくても良いので、
無名クラスを使うと次のように短く書くことがでる。

```scala
import scala.language.implicitConversions
import scala.language.reflectiveCalls

implicit def Pipeline[T](x: T) = new {
  def |>[S](f: T => S): S = f(x)
}

123 |> (_ * 2) |> println // => 246
```


[^1]: implicit キーワードは暗黙的な変換（Implicit Conversions）に由来する。
[^2]: Scala の演算子は全てメソッド。例えば `a == b` は `a.==(b)` に等しい。
