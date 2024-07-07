---
layout:        post
title:         "[C#] Reflectionでプロパティ一覧を動的に取得する"
date:          2024-07-08
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

C# のメタプログラミング (Reflection) で、クラスに定義されているプロパティ一覧を取得するには Type#GetProperties メソッドを使用します。
プロパティ名を動的に取得する方法は以下の通りです。

1. 対象のクラスを **typeof** または **GetType** で Type 型に変換する。
    - クラスから型を取得したいときは `Type t = typeof(MyPropertyClass);`
    - インスタンスから型を取得したいときは `Type t = new MyPropertyClass().GetType();`
    - 文字列から型を取得したいときは `Type t = Type.GetType("System.String", true);`
2. Type型のメソッド **GetProperties** を呼び出す。
    - [Type.GetProperty メソッド (System)](https://learn.microsoft.com/ja-jp/dotnet/api/system.type.getproperty?view=net-8.0)
    - 引数は検索対象とするフィールドの属性のフラグをビットOR演算子で繋げて記載する。
        - 検索時のフラグの一覧は [BindingFlags 列挙型 (System.Reflection)](https://learn.microsoft.com/ja-jp/dotnet/api/system.reflection.bindingflags?view=net-8.0) を参照
3. 返り値は PropertyInfo 型の配列になる。
4. PropertyInfo 型のプロパティ **Name** (string) や **PropertyType** (Type) などからプロパティに関する情報を取得する。
    - [PropertyInfo クラス (System.Reflection)](https://learn.microsoft.com/ja-jp/dotnet/api/system.reflection.propertyinfo?view=net-8.0)
5. （任意）インスタンスからプロパティの値を取得したいときは、PropertyInfo 型のプロパティ GetMethod からメソッド情報 (MethodInfo型) を取得する。
    - [MethodInfo クラス (System.Reflection)](https://learn.microsoft.com/ja-jp/dotnet/api/system.reflection.methodinfo?view=net-8.0)

まず、検証用のクラス MyPropertyClass が定義されているとします。

```csharp
public class MyPropertyClass
{
    public string? Property1 { get { return "value1"; } }
    public string? Property2 { get; set; }
    protected string? Property3 { get; }
    private int Property4 { get; }
    internal string? Property5 { get; }
    protected internal string? Property6 { get; }
}
```

このクラスに対して、以下のように実装することで、プロパティの一覧を取得することができます。

```csharp
Type t = typeof(MyPropertyClass);

PropertyInfo[] publicPropInfos = t.GetProperties(BindingFlags.Public | BindingFlags.Instance);
Console.WriteLine($"Publicなプロパティの個数: {publicPropInfos.Length}");
DisplayPropertyInfo(publicPropInfos);

PropertyInfo[] nonpublicPropInfos = t.GetProperties(BindingFlags.NonPublic | BindingFlags.Instance);
Console.WriteLine($"Publicではないプロパティの個数: {nonpublicPropInfos.Length}");
DisplayPropertyInfo(nonpublicPropInfos);

void DisplayPropertyInfo(PropertyInfo[] propInfos)
{
    foreach (var propInfo in propInfos) {
        Console.WriteLine("  Property name: {0}", propInfo.Name);
        Console.WriteLine("  Property type: {0}", propInfo.PropertyType);
        Console.WriteLine("  Read-Write:    {0}", propInfo.CanRead & propInfo.CanWrite);
        if (propInfo.CanRead) {
            MethodInfo? getAccessor = propInfo.GetMethod;
            // Getterに関する情報を取得
        }
        if (propInfo.CanWrite) {
            MethodInfo? setAccessor = propInfo.SetMethod;
            // Setterに関する情報を取得
        }
        Console.WriteLine();
    }
}
```

PropertyInfo 型には以下のプロパティが存在します。

- .Name : プロパティの名前 (string)
- .PropertyType : プロパティの型 (Type)
- .CanRead : Getterが存在するときTrue
- .CanWrite : Setterが存在するときTrue
- .GetMethod : Getterのメソッドに関する情報
- .SetMethod : Setterのメソッドに関する情報

GetProperties を呼び出すことで PropertyInfo の配列が取得できるので、これを foreach で回すことで全てのプロパティを取得することができます。

<br>

以下はサンプルとなるプログラムの全体です。

```csharp
using System.Reflection;

namespace Example
{
    public class MyPropertyClass
    {
        public string? Property1 { get { return "value1"; } }
        public string? Property2 { get; set; }
        protected string? Property3 { get; }
        private int Property4 { get; }
        internal string? Property5 { get; }
        protected internal string? Property6 { get; }
    }

    public class ExampleGetProperties
    {
        public static void Main()
        {
            Type t = typeof(MyPropertyClass);

            PropertyInfo[] publicPropInfos = t.GetProperties(BindingFlags.Public | BindingFlags.Instance);
            Console.WriteLine($"Publicなプロパティの個数: {publicPropInfos.Length}");
            DisplayPropertyInfo(publicPropInfos);

            PropertyInfo[] nonpublicPropInfos = t.GetProperties(BindingFlags.NonPublic | BindingFlags.Instance);
            Console.WriteLine($"Publicではないプロパティの個数: {nonpublicPropInfos.Length}");
            DisplayPropertyInfo(nonpublicPropInfos);

            void DisplayPropertyInfo(PropertyInfo[] propInfos)
            {
                foreach (var propInfo in propInfos) {
                    Console.WriteLine("  Property name: {0}", propInfo.Name);
                    Console.WriteLine("  Property type: {0}", propInfo.PropertyType);
                    Console.WriteLine("  Read-Write:    {0}", propInfo.CanRead & propInfo.CanWrite);
                    if (propInfo.CanRead) {
                        MethodInfo? getAccessor = propInfo.GetMethod;
                        if (getAccessor != null)
                            Console.WriteLine($"  Visibility:    {GetVisibility(getAccessor)}");
                    }
                    if (propInfo.CanWrite) {
                        MethodInfo? setAccessor = propInfo.SetMethod;
                        if (setAccessor != null)
                            Console.WriteLine($"  Visibility:    {GetVisibility(setAccessor)}");
                    }
                    Console.WriteLine();
                }
            }

            string GetVisibility(MethodInfo accessor)
            {
                if (accessor.IsPublic)
                    return "Public";
                else if (accessor.IsPrivate)
                    return "Private";
                else if (accessor.IsFamily)
                    return "Protected";
                else if (accessor.IsAssembly)
                    return "Internal/Friend";
                else
                    return "Protected Internal/Friend";
            }
        }
    }
}
```

プログラムを実行すると以下の結果が出力されます。

```output
Publicなプロパティの個数: 2
  Property name: Property1
  Property type: System.String
  Read-Write:    False
  Visibility:    Public

  Property name: Property2
  Property type: System.String
  Read-Write:    True
  Visibility:    Public
  Visibility:    Public

Publicではないプロパティの個数: 4
  Property name: Property3
  Property type: System.String
  Read-Write:    False
  Visibility:    Protected

  Property name: Property4
  Property type: System.Int32
  Read-Write:    False
  Visibility:    Private

  Property name: Property5
  Property type: System.String
  Read-Write:    False
  Visibility:    Internal/Friend

  Property name: Property6
  Property type: System.String
  Read-Write:    False
  Visibility:    Protected Internal/Friend
```

以上です。
