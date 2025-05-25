---
layout:        post
title:         "[C#] マルチスレッド処理：例外処理とAggregateException"
date:          2025-05-23
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

マルチスレッド処理において、Task内で発生した例外はawaitを使うと例外をそのまま再スローします。
awaitではなく、Task#Waitメソッドを使うとAggregateExceptionに包まれて例外がスローされます。


## Task#Waitの場合（AggregateException）

Task.Wait()メソッドで例外が発生した場合、スローされるのは AggregateException です。
AggregateException の InnerException プロパティには、実行中のタスク内で発生した例外が格納されます。
具体的には以下のようになります：

- AggregateException.**InnerExceptions**（コレクション）には、タスク内で発生したすべての例外が格納されます。
- AggregateException.**InnerException**（単一の例外）には、InnerExceptions の最初の例外（InnerExceptions[0]）が格納されます。

```cs
using System;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Concurrent;

class WaitExceptionExample
{
    public static void Main()
    {
        try
        {
            Task task = SomeMethod();
            task.Wait();
        }
        catch (AggregateException ex)
        {
            Console.Error.WriteLine($"[!] Error: {ex.InnerException?.GetType()}: {ex.InnerException?.Message}");
            // => [!] Error: System.NotImplementedException: 未実装です！
        }
    }

    public static async Task SomeMethod()
    {
        await Task.Yield();
        throw new NotImplementedException("未実装です！");
    }
}
```

## awaitの場合

await は非同期メソッドの中で発生した個々の例外をそのまま再スローします。
そのため、try-catch ブロックで await を囲むと、直接その例外型（例：InvalidOperationExceptionなど）として捕捉できます。

```cs
using System;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Concurrent;

class AwaitExceptionExample
{
    public static async Task Main()
    {
        try
        {
            await OtherMethod();
        }
        catch (NotImplementedException ex)
        {
            Console.Error.WriteLine($"[!] Error: {ex.GetType()}: {ex.Message}");
            // => [!] Error: System.NotImplementedException: 未実装です！
            throw;
        }
    }

    public static async Task OtherMethod()
    {
        await Task.Yield();
        throw new NotImplementedException("未実装です！");
    }
}
```

ただし、`await Task.WhenAll(...)` などの複数タスクをawaitした場合は、AggregateExceptionに例外が集約されてスローされます。


## AggregateException#Handle

Task.Waitメソッドを使用する際には、非同期操作中に発生した例外がすべてAggregateExceptionとしてまとめてスローされる点に注意が必要です。
例外AggregateExceptionは、非同期タスク内で発生した複数の例外を1つに集約するため、例外処理を行う際には内部のInnerExceptionsコレクションを適切に確認・処理する必要があります。
処理するときは AggregateException#Handle メソッドを使うことで、例外を1つずつ処理することができます。

```cs
using System;
using System.Threading;
using System.Collections.Concurrent;
using System.Threading.Tasks;

class StartAsyncAwaitExample
{
    public static void Main()
    {
        Task[] ts = new Task[3];
        ts[0] = Task.Run(() => { throw new Exception("Sample Error 1"); });
        ts[1] = Task.Run(() => { throw new Exception("Sample Error 2"); });
        ts[2] = Task.Run(() => { throw new Exception("Sample Error 3"); });
        Task? t = null;
        try
        {
            t = Task.WhenAll(ts);
            t.Wait();
        }
        catch (AggregateException ae)
        {
            ae.Handle((ex) =>
            {
                Console.Error.WriteLine($"[!] Error: {ex.GetType()}: {ex.Message}");
                return true;  // falseを返すとAggregateExceptionが親メソッドに伝播する
            });
        }
        // => [!] Error: System.Exception: Sample Error 1
        // => [!] Error: System.Exception: Sample Error 2
        // => [!] Error: System.Exception: Sample Error 3
    }
}
```

AggregateException#Handle メソッドのラムダ式の中で、falseを返すとAggregateExceptionが親メソッドに伝播します。
trueを返すとAggregateExceptionの例外が握り潰されます。

以上です。
