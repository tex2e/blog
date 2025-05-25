---
layout:        post
title:         "[C#] マルチスレッド処理：async/awaitで並列処理"
date:          2025-05-22
category:      Dotnet
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

`async` と `await` キーワードを使用することで、シンプルに非同期処理を作成できるようになり、非同期プログラミングの複雑な設定や継続処理の定義をする必要がなくなり、コードの可読性に関わる「コールバック地獄」の問題を解消することができます。

## 非同期メソッドから非同期メソッドを呼び出す

asyncメソッド（非同期メソッド）から別のasyncメソッド（非同期メソッド）を呼び出すときは、メソッド呼び出しの前にawaitキーワードを付けます。
こうすることで、Task#Wait() してから、Task#Result を取得した結果と同じになります。

```cs
using System;
using System.Threading;
using System.Collections.Concurrent;

class StartAsyncAwaitExample
{
    public static async Task Main()
    {
        // asyncメソッドから別のasyncメソッドを呼び出すときは await で待機する
        string result = await OtherMethod();

        Console.WriteLine($"result={task.Result}");
        // => result=100
    }

    public static async Task<string> OtherMethod()
    {
        await Task.Yield();
        return "100";
    }
}
```

## 同期メソッドから非同期メソッドを呼び出す

asyncではないメソッド（同期メソッド）からasyncメソッド（非同期メソッド）を呼び出すときは、返り値をTaskインスタンスとして受け取り、Task#Wait() してから、Task#Result を取得しします。

```cs
using System;
using System.Threading;
using System.Collections.Concurrent;

class StartAsyncAwaitExample
{
    public static void Main()
    {
        // asyncではないメソッドからasyncメソッドを呼び出したら Wait() で待機する
        Task task = SomeMethod();
        task.Wait();

        Console.WriteLine($"result={task.Result}");
        // => result=200
    }

    public static async Task<string> SomeMethod()
    {
        await Task.Yield();
        return "200";
    }
}
```

## （補足）awaitのコンパイル時の変換

`await` キーワードは C# の `Task` 完了後の継続処理の付加を単純にします。
例えば、次のプログラムを実装したとします。

```cs
await expression;
statement(s);
```

すると、コンパイラが次のような継続処理を行う処理に内部的に変換します。

```cs
expression.GetAwaiter().OnCompleted(() => statement(s));
```

`await` キーワードは、現在のスレッドをブロックすることなく、非同期操作の結果が利用可能になったときにその結果を取得するための方法です。
これにより、`await` の後の処理は、非同期操作が完了した後に実行される継続処理として扱われます。
また、`await` は現在待機しているタスクに例外や問題がないことを検証する機能もあるため、スレッドやタスクで取りこぼしていた例外が正しく拾えるようになります。


以上です。
