---
layout:        post
title:         "[VB.NET] 無名関数の使い方"
date:          2022-12-15
category:      VB.NET
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

VB.NETにおいて関数 (Function) を変数にセットするときは、その型は Func(Of ...) で定義します。
同様にサブルーチン (Sub) を変数にセットするときは、その型は Action(Of ...) で定義します。

* Func型では引数の型と返り値の型を指定します。
  `Func(Of 引数1の型, 引数2の型, ..., 返り値の型)` と書きます。
* Action型では引数の型のみを指定します。
  `Action(Of 引数1の型, 引数2の型, ...)` と書きます。

変数にセットした関数やサブルーチンの呼び出し方は、`変数名(引数)` と書き、通常の関数呼び出しと同じです。

```vb
Module Module1
    Sub Main()
        '関数 (Function) の無名関数化
        '                  引数1     引数2     返り値
        Dim add As Func(Of Integer, Integer, Integer) =
            Function(a As Integer, b As Integer)
                Return a + b
            End Function
        Console.WriteLine(add(2, 3))
        '=> 5

        'サブルーチン (Sub) の無名関数化
        '                         引数1
        Dim sayHello As Action(Of String) =
            Sub(name As String)
                Console.WriteLine(String.Format("Hello, {0}!", name))
            End Sub
        sayHello("tex2e")
        '=> Hello, tex2e!

        '高階関数の使用例
        testResult(4, Function(num) num Mod 2 = 0)
        '=> Success!

        Console.ReadLine()
    End Sub

    '高階関数の定義
    Sub testResult(value As Integer, fun As Func(Of Integer, Boolean))
        If fun(value) Then
            Console.WriteLine("Success!")
        Else
            Console.WriteLine("Failure!")
        End If
    End Sub
End Module
```

なお、無名関数はVisual Basic 2010以降で利用できる言語機能になります。

以上です。
