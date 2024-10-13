---
layout:        post
title:         "[C#] デコレータパターンを実装する"
date:          2024-07-07
category:      Dotnet
cover:         /assets/cover14.jpg
redirect_from: /c%23/decorator-pattern
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

C# でデザインパターンの1つであるデコレータパターン (Decorator Pattern) を実装する方法について説明します。

デコレータパターンとは、構造に関するデザインパターンの一つで、ある振る舞いをラッパーで包み込むことで、元々の振る舞いに手を入れることなく、新しい振る舞いを付け加えることができる設計方法です。

以下は、挨拶を印字するための関数 MyFunction の呼び出し時に、開始と終了のログをstdoutに出力する処理を付け加えるための高階関数 MyDecorator を定義して使用する例です。

```csharp
public static void Main()
{
    string res = MyDecorator("MyFunction()", () => MyFunction("YOUR NAME"));
    Console.WriteLine(res);
}

static string MyFunction(string message)
{
    return $"Hello, {message}!";
}

public static T MyDecorator<T>(string methodName, Func<T> func)
{
    Console.WriteLine($"[*] Start {methodName}");
    try
    {
        return func();
    }
    finally
    {
        Console.WriteLine($"[*] Finished {methodName}");
    }
}
```

上記のプログラムを実行すると、以下の結果が出力されます。

```output
[*] Start MyFunction()
[*] Finished MyFunction()
Hello, YOUR NAME!
```

以上です。
