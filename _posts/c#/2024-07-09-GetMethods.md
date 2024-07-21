---
layout:        post
title:         "[C#] Reflectionでメソッド一覧を動的に取得する"
date:          2024-07-09
category:      C#
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

C# のメタプログラミング (Reflection) で、クラスに定義されているメソッド一覧を取得するには Type#GetMethods メソッドを使用します。
メソッド一覧を動的に取得する方法は以下の通りです。

1. 対象のクラスを **typeof** または **GetType** で Type 型に変換する。
    - クラスから型を取得したいときは `Type t = typeof(MyPropertyClass);`
    - インスタンスから型を取得したいときは `Type t = new MyPropertyClass().GetType();`
    - 文字列から型を取得したいときは `Type t = Type.GetType("System.String", true);`
1. Type#**GetMethods** を呼び出して、メソッドの一覧を取得する。
    - [Type.GetMethod メソッド (System)](https://learn.microsoft.com/ja-jp/dotnet/api/system.type.getmethod?view=net-8.0)
    - 引数は検索対象とするフィールドの属性のフラグをビットOR演算子で繋げて記載する。
    - 検索時のフラグの一覧は [BindingFlags 列挙型 (System.Reflection)](https://learn.microsoft.com/ja-jp/dotnet/api/system.reflection.bindingflags?view=net-8.0) を参照
        - BindingFlags.Public : 公開メソッドのみ抽出する（プライベートメソッドなどは除外する）
        - BindingFlags.Instance : インスタンスメソッドのみ抽出する（クラスメソッドは除外する）
        - BindingFlags.DeclaredOnly : 自分のクラスで定義したメソッドのみ抽出する（継承したメソッドは除外する）
1. MethodInfo 型の配列が返り値として得られる。
1. MethodInfo のプロパティ .Name やメソッド GetParameters() などからメソッドの情報を取得する。
1. （任意）MethodInfo#**Invoke** メソッドを使って、取得した情報でメソッド呼び出しを行う。
    - 第1引数には、インスタンスを指定する。
    - 第2引数には、メソッドの引数を object 型の配列で指定する。


```csharp
using System.Reflection;

public class MyClass
{
    public string MyMethod1(string arg1, string arg2)
    {
        return $"[MyMethod1] arg1={arg1}, arg2={arg2}";
    }

    public string MyMethod2(string arg1, string arg2)
    {
        return $"[MyMethod2] arg1={arg1}, arg2={arg2}";
    }
}

public class ExampleGetMethod
{
    public static void Main()
    {
        var myobj = new MyClass();

        Type t = myobj.GetType();

        MethodInfo[] methodInfos = t.GetMethods(
            BindingFlags.Public | BindingFlags.Instance | BindingFlags.DeclaredOnly);
        Console.WriteLine($"公開メソッドの数：{methodInfos.Length}");

        foreach (MethodInfo methodInfo in methodInfos) {
            // myobj.MyMethodX("123", "456") を動的メソッド呼び出しで実現する
            var res = methodInfo.Invoke(myobj, new object[] { "123", "456" });
            Console.WriteLine($"result: {res}");
        }

    }
}
```

プログラムを実行すると以下の結果が出力されます。

```output
公開メソッドの数：2
result: [MyMethod1] arg1=123, arg2=456
result: [MyMethod2] arg1=123, arg2=456
```

以上です。
