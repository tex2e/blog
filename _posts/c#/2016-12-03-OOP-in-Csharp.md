---
layout:        post
title:         "OOP in C#"
date:          2016-12-03
category:      C#
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      false
published:     true
---

C# におけるオブジェクト指向のまとめ

目次
-------

- [クラスの定義](#class)
- [コンストラクタ、フィールド、メソッド](#constructor)
- [プロパティ](#properties)
- [自動実装プロパティ](#auto-implemented-properties)
- [クラスメソッド、クラス変数](#class-method)
- [アクセス権](#access)
- [オーバーロード](#overload)
- [演算子の定義](#operator)
- [継承、オーバーライド](#extends)
- [抽象クラス](#abstract)
- [インターフェース](#interface)
- [ジェネリックス](#generics)
- [拡張メソッド](#extender)
- [イベント](#event)


<a name="class"></a>

クラスの定義
-----------

- `class` というキーワードでクラスを宣言
- `new クラス名()` でインスタンスの生成

```csharp
class Foo {}

class Program {
    static void Main() {
        Foo foo = new Foo();
    }
}
```

<a name="constructor"></a>

コンストラクタ、フィールド、メソッド
------------------------------

- クラス名と同名の関数を宣言するとコンストラクタになります
 （コンストラクタの返り値は書かない）
- フィールドとメソッドのアクセス修飾子を省略した場合は、デフォルトで private になります

```csharp
using System.IO;
using System;

class Point {
    // フィールド
    public int x, y;

    // コンストラクタ
    public Point(int x, int y) {
        this.x = x;
        this.y = y;
    }

    // メソッド
    public Point Add(Point other) {
        return new Point(this.x + other.x, this.y + other.y);
    }

    public override string ToString() {
        return "(" + this.x + ", " + this.y + ")";
    }
}

class Program {
    static void Main() {
        Point p1 = new Point(1, 2);
        Point p2 = new Point(3, 4);
        Console.WriteLine(p1.Add(p2)); // => "(4, 6)"
    }
}
```

メソッドはラムダ式を使って定義することもできます（C# 6.0）。

```csharp
class Point {
    // ...

    // メソッド
    public Point Add(Point other)
        => new Point(this.x + other.x, this.y + other.y);

    public override string ToString()
        => "(" + this.x + ", " + this.y + ")";
}
```


<a name="properties"></a>

プロパティ
----------------------

- C# の __プロパティ__ とは、フィールドとメソッドの両方の機能を持つものです
- 宣言の仕方は `型名 プロパティ名 { get { ... } set { ... } }` です
- `get` や `set` はデフォルトで public ですが、`private` 修飾子をつけることで private にすることができます

```csharp
using System.IO;
using System;

class Point {
    // フィールド
    private int _x;
    private int _y;
    // プロパティ
    public int x {
        get { return this._x; }
        private set { this._x = value; }
        // value はプロパティの setter が受け取る引数が代入される、あらかじめ定義された変数
    }
    public int y {
        get { return this._y; }
        private set { this._y = value; }
    }

    // コンストラクタ
    public Point(int x, int y) {
        this.x = x;
        this.y = y;
    }
}

class Program {
    static void Main() {
        Point p = new Point(1, 2);
        Console.WriteLine(p.x);
        p.x = 0; // error
    }
}
```


<a name="auto-implemented-properties"></a>

自動実装プロパティ
------------------------

- プロパティの getter と setter を自動で実装するには、
  __自動実装プロパティ__ （auto-implemented properties）を利用します
- インスタンス変数の宣言の後にブロックを書き、
    - その中で `get;` と書くと `get { return this.インスタンス変数名 }` と展開されます。
    - その中で `set;` と書くと `set { this.インスタンス変数名 = value }` と展開されます。


```csharp
using System.IO;
using System;

class Point {
    // フィールド
    public int x { get; private set; } // getter は public、setter は private
    public int y { get; private set; }

    // コンストラクタ
    public Point(int x, int y) {
        this.x = x;
        this.y = y;
    }
}

class Program {
    static void Main() {
        Point p = new Point(1, 2);
        Console.WriteLine(p.x);
        //p.x = 0; // error
    }
}
```

また、自動プロパティの初期化も行うことができます（C# 6.0）。

```csharp
class Point {
    public int x { get; private set; } = 0;
    public int y { get; private set; } = 0;
}
```


<a name="class-method"></a>

クラスメソッド、クラス変数
------------------------------

- クラスメソッドは `static` 修飾子を使います
- クラス変数も `static` 修飾子を使います

```csharp
using System.IO;
using System;

class User {
    // staticフィールド
    private static int userCount = 0;

    public string name { get; private set; }
    private int age;

    public User(string name, int age) {
        IncrementUserCount();
        this.name = name;
        this.age = age;
    }

    // staticメソッド
    public static int GetUserCount() {
        return User.userCount;
    }

    private static void IncrementUserCount() {
        User.userCount += 1;
    }
}

class Program {
    static void Main() {
        Console.WriteLine(User.GetUserCount()); // => 0
        User alice = new User("Alice", 20);
        User bob   = new User("Bob", 22);
        Console.WriteLine(User.GetUserCount()); // => 2
    }
}
```


<a name="access"></a>

アクセス権
-----------

アクセス修飾子は public と private と protected の3種類あります。
アクセス修飾子を省略した場合は、private になります。


<a name="overload"></a>

オーバーロード
-------------

同じ名前のメソッドを定義することでオーバーロードすることができます。

```csharp
using System.IO;
using System;

class Sample {
    public static int foo(int x) {
        return x + 1;
    }
    public static string foo(string x) {
        return x + "1";
    }
}

class Program {
    static void Main() {
        Console.WriteLine(Sample.foo(123));   // => 124
        Console.WriteLine(Sample.foo("123")); // => "1231"
    }
}
```


<a name="operator"></a>

演算子の定義
-----------------------

- 演算子をオーバーロードするときは、`operator+` のように operator を演算子の前に付けてメソッド宣言を行います
- 演算子のメソッドはクラスメソッドとして定義し、2つの引数（左オペランド, 右オペランド）をとるように宣言します

```csharp
using System.IO;
using System;

class Point {
    public int x, y;

    public Point(int x, int y) {
        this.x = x;
        this.y = y;
    }

    // +演算子の再定義
    public static Point operator+ (Point right, Point left) {
        return new Point(right.x + left.x, right.y + left.y);
    }

    public override string ToString() {
        return "(" + this.x + ", " + this.y + ")";
    }
}

class Program {
    static void Main() {
        Point p1 = new Point(1, 2);
        Point p2 = new Point(3, 4);
        Console.WriteLine(p1 + p2); // => "(4, 6)"
    }
}
```


<a name="extends"></a>

継承、オーバーライド
------------------

- 継承をするには `class 子クラス : 親クラス` と書きます
- 親クラスへの参照は `base` を使います
- オーバーライドをするには、`override` 修飾子を付けます
- オーバーライドされるメソッドは、
  すでに実装がある場合は `virtual`、実装がない場合は `abstract` 修飾子をメソッド定義に付けます

```csharp
using System.IO;
using System;

class A {
    public virtual void Foo() {
        Console.WriteLine("A's method Foo()");
    }
}

class B : A {
    public override void Foo() {
        Console.WriteLine("B's method Foo()");
        base.Foo();
    }
}

class Program {
    static void Main() {
        B b = new B();
        b.Foo();
        // => "B's method Foo()"
        // => "A's method Foo()"
    }
}
```


<a name="abstract"></a>

抽象クラス
-----------------------

抽象クラス・抽象メソッドを定義するには、`abstract` キーワードを付けます。

```csharp
using System.IO;
using System;

// 抽象クラスの定義
abstract class AbstractMusic {
    public abstract void Play();
    public abstract void Stop();
}

class Music : AbstractMusic {
    public override void Play() {
        Console.WriteLine("play!");
    }
    public override void Stop() {
        Console.WriteLine("stop!");
    }
}

class Program {
    static void Main() {
        Music music = new Music();
        music.Play(); // => "play!"
    }
}
```


<a name="interface"></a>

インターフェース
------------------

- インターフェースを定義するには、`interface インターフェース名 { ... }` と書きます
- C# のインターフェースは Java とは違い、インターフェースに定数などの変数を宣言することはできないです
- C# のインターフェースで宣言できる抽象メンバは、以下の通りです
    - メソッド
    - プロパティ
    - インデクサ
    - イベント
- interface で宣言するメンバは全て public abstract であると見なされるため、
  これらの修飾子は不要です（明示的に書くとエラーで怒られる）。

```csharp
// インターフェースの定義
interface USBInterface {
    // インターフェースで宣言できるメソッドは、名前のみ
    bool connectUSB();
    bool disconnectUSB();
}

class Printer : USBInterface {
    // インターフェースの実装
    public bool connectUSB() {
        // ...
        return true;
    }
    public bool disconnectUSB() {
        // ...
        return true;
    }
}
```


<a name="generics"></a>

ジェネリックス
------------------

- __ジェネリック__ とは、クラスやメソッドで型の種類を引数で取ることです
- ジェネリックは `class クラス名<仮の型名>` で型を取ることができます
- ジェネリックの型に制約をつける場合は、ジェネリックの宣言をした後に、`where 仮の型名 : 制約` と書きます
    - `where 仮の型名 : クラス名` は、その型をそのクラスの派生クラスに制限します
    - `where 仮の型名 : インターフェース名` は、その型をそのインターフェースが実装してあるクラスに制限します


```csharp
using System.IO;
using System;

// ジェネリックなRangeクラスの作成
// 型は、IComparableインターフェースを実装しているクラスに制限している
class Range<T> where T : IComparable {
    T begin;
    T end;

    public Range(T begin, T end) {
        if (begin.CompareTo(end) > 0) {
            throw new System.ArgumentException("begin must be less than end");
        }
        this.begin = begin;
        this.end   = end;
    }

    public bool include(T item) {
        return (item.CompareTo(begin) >= 0 && item.CompareTo(end) < 0);
    }
}


class Program {
    static void Main() {
        Range<int> intRange = new Range<int>(1, 9);
        Console.WriteLine(intRange.include(5)); // => True

        Range<string> stringRange = new Range<string>("a", "e");
        Console.WriteLine(stringRange.include("c")); // => True
        Console.WriteLine(stringRange.include("z")); // => False
    }
}
```

`default` キーワードを用いると、ジェネリックの型でも初期値を設定することができます。

```csharp
using System.IO;
using System;

class DefaultTest<T> {
    public T GetDefault() {
        return default(T);
    }
}


class Program {
    static void Main() {
        Console.WriteLine( new DefaultTest<int>().GetDefault() );    // => 0
        Console.WriteLine( new DefaultTest<string>().GetDefault() ); // => null
    }
}
```


<a name="extender"></a>

拡張メソッド
------------------

既存のクラスを継承せずにメソッドだけを拡張するには、
「static なクラス（名前はなんでも良い）に static なメソッドを定義し、その引数に拡張するクラスを取り、その引数の前に `this` を付けます。」


```csharp
using System.IO;
using System;
using System.Text.RegularExpressions;

// 拡張メソッドの定義
public static class StringExtender {
    public static string ToAlphanumeric(this string str) {
        return Regex.Replace(str, @"[^\w\s]+", "");
    }
}

class Program {
    static void Main() {
        string str = "abc 123 </> edf";
        Console.WriteLine(str.ToAlphanumeric()); // => "abc 123  edf"
    }
}
```


<a name="event"></a>

イベント
------------------

- イベントの宣言は、`event デリゲート型名 イベント名` と書きます
- C# は標準で `EventHandler(object, EventArgs)` というデリゲートを提供しています
- イベントは、技術的にはデリゲート（delegate）と同じなので、イベントハンドラの登録をするときは
  `+=` で追加していきます

```csharp
using System.IO;
using System;

class Mouse {
    // イベント（メンバ変数と同じようにアクセスできる）
    public event EventHandler onClick;

    // Clickメソッドが呼び出されたら、イベントを発火させる
    public void Click() {
        if (onClick != null) {
            onClick(this, EventArgs.Empty);
        }
    }
}

class Program {
    static void Main() {
        Mouse mouse = new Mouse();
        // イベントハンドラの登録
        mouse.onClick += (obj, e) => Console.WriteLine("event handler1: mouse was clicked!");
        mouse.onClick += (obj, e) => Console.WriteLine("event handler2: mouse was clicked!");

        mouse.Click();
        // => "event handler1: mouse was clicked!"
        // => "event handler2: mouse was clicked!"
    }
}
```
