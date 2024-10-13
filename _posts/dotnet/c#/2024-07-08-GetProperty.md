---
layout:        post
title:         "[C#] Reflectionでプロパティ値を動的に取得する"
date:          2024-07-08
category:      Dotnet
cover:         /assets/cover14.jpg
redirect_from: /c%23/GetProperty
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

C# のメタプログラミング (Reflection) で、インスタンスのプロパティ値を動的に取得するには、Type#GetProperty メソッドを使用します。
プロパティ値を動的に取得する方法は以下の通りです。

1. 調査対象のインスタンスを用意する。
1. インスタンスのクラスを Type#**GetType** で Type 型を取得する。
    - クラスから型を取得したいときは `Type t = typeof(MyPropertyClass);`
    - インスタンスから型を取得したいときは `Type t = new MyPropertyClass().GetType();`
    - 文字列から型を取得したいときは `Type t = Type.GetType("System.String", true);`
1. Type#**GetProperty** メソッドの引数にプロパティ名の文字列を渡して実行する。
    - [Type.GetProperty メソッド (System)](https://learn.microsoft.com/ja-jp/dotnet/api/system.type.getproperty?view=net-8.0)
1. 取得できないときは null、取得できたときは PropertyInfo 型が返り値として得られる。
1. PropertyInfo#**GetValue** メソッドの引数にインスタンスを渡すことで、そのインスタンスにあるプロパティの値を取得することができる。
    - [PropertyInfo クラス (System.Reflection)](https://learn.microsoft.com/ja-jp/dotnet/api/system.reflection.propertyinfo?view=net-8.0)
    - [PropertyInfo.GetValue メソッド (System.Reflection)](https://learn.microsoft.com/ja-jp/dotnet/api/system.reflection.propertyinfo.getvalue?view=net-8.0#system-reflection-propertyinfo-getvalue%28system-object-system-object%28%29%29)

```csharp
using System.Reflection;

// 検証用クラス
public class MyPropertyClass
{
    public int Property1 { get; set; }
    public string? Property2 { get; set; }
}

public class ExampleGetProperties
{
    public static void Main()
    {
        var myprop = new MyPropertyClass() {
            Property1 = 123,
            Property2 = "hello"
        };

        Type t = myprop.GetType();

        PropertyInfo? propInfo1 = t.GetProperty("Property1");  // プロパティ情報の取得
        Console.WriteLine($"プロパティ名: {propInfo1?.Name}");
        Console.WriteLine($"プロパティ型: {propInfo1?.PropertyType}");
        Console.WriteLine($"プロパティ値: {propInfo1?.GetValue(myprop)}");  // プロパティ値の取得
        Console.WriteLine();

        PropertyInfo? propInfo2 = t.GetProperty("Property2");  // プロパティ情報の取得
        Console.WriteLine($"プロパティ名: {propInfo2?.Name}");
        Console.WriteLine($"プロパティ型: {propInfo2?.PropertyType}");
        Console.WriteLine($"プロパティ値: {propInfo2?.GetValue(myprop)}");  // プロパティ値の取得
        Console.WriteLine();
    }
}
```

プログラムを実行すると以下の結果が出力されます。

```output
プロパティ名: Property1
プロパティ型: System.Int32
プロパティ値: 123

プロパティ名: Property2
プロパティ型: System.String
プロパティ値: hello
```

以上です。
