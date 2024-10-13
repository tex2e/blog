---
layout:        post
title:         "[C#] Reflectionで属性付きメソッドの一覧を動的に取得する"
date:          2024-07-10
category:      Dotnet
cover:         /assets/cover14.jpg
redirect_from: /c%23/GetMethodsByAttribute
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

C# のメタプログラミング (Reflection) で、クラスに定義されていて属性 (Custom Attributes) が付けられたメソッド一覧を取得するには Type#GetMethods メソッドと MethodInfo#IsDefined を組み合わせることで実現することができます。
属性 (Custom Attributes) 付きのメソッド一覧を動的に取得する方法は以下の通りです。

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
1. if文の条件で、MethodInfo#**IsDefined** メソッドを使って、カスタム属性 (Custom Attributes) が調査対象のメソッドに付与されているか確認する。
    - [MemberInfo.IsDefined(Type, Boolean) メソッド (System.Reflection)](https://learn.microsoft.com/ja-jp/dotnet/api/system.reflection.memberinfo.isdefined?view=net-8.0#system-reflection-memberinfo-isdefined%28system-type-system-boolean%29)
    - 第1引数には、付与されているカスタム属性の型 (Type型) を指定する。
    - 第2引数は、true を指定して、継承元があれば親クラスまでさかのぼって検索する。

```csharp
using System.Reflection;

[AttributeUsage(AttributeTargets.Method)]
public class MyAttribute : Attribute
{}

public class MyClass
{
    [MyAttribute]
    public string MyMethod1() { return "1"; }

    [MyAttribute]
    public string MyMethod2() { return "2"; }

    public string MyMethod3() { return "3"; }

    public string MyMethod4() { return "4"; }

    [MyAttribute]
    public string MyMethod5() { return "5"; }
}

public class ExampleGetMethodsByAttribute
{
    public static void Main()
    {
        var myobj = new MyClass();

        Type t = myobj.GetType();

        MethodInfo[] methodInfos = t.GetMethods(
            BindingFlags.Public | BindingFlags.Instance | BindingFlags.DeclaredOnly);

        foreach (MethodInfo methodInfo in methodInfos) {
            if (methodInfo.IsDefined(typeof(MyAttribute), true)) {
                // 調査対象のメソッドにカスタム属性が付与されているときのみ、メソッドを実行する
                var res = methodInfo.Invoke(myobj, new object[] {});
                Console.WriteLine($"result: {res}");
            }
        }
    }
}
```

プログラムを実行すると以下の結果が出力されます。
今回の例では、メソッド MyMethod1, MyMethod2, MyMethod5 のみが実行されており、それぞれはカスタム属性の [MyAttribute] が付与されたものだけが実行されています。

```output
result: 1
result: 2
result: 5
```

以上です。
