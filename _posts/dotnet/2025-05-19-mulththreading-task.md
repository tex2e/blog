---
layout:        post
title:         "[C#] マルチスレッド処理：Taskクラスで並列処理"
date:          2025-05-19
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

Taskを使用したスレッドプールを起動する方法は、Threadクラスでスレッドを立てるよりもマルチスレッド処理におけるパフォーマンスが向上します。
この記事では、Taskを使った並列処理の実装方法について説明します。

スレッドプールはTaskクラスを使って利用できます。
Task#Runメソッドで、引数のラムダ式をスレッドプールで実行するために登録できます。
利用可能なスレッドがプールにあれば即座に実行を開始しますが、利用可能なスレッドがなければスレッドが利用できるようになるまでキューの中で待機されます。


### 返り値なしの Task

返り値がないタスクであれば、返り値の型は `Task` となります。
以下は、タスクを作成して起動する例です。

```cs
class StartTaskExample
{
    static void Main(string[] args)
    {
        string url = "https://example.com";

        // タスクの作成と起動
        Task t = Task.Run(() =>
            {
                Console.WriteLine($"[*] Downloading {url}");
            });

        // タスクが終了するまで待機
        t.Wait();
        // => [*] Downloading https://example.com
    }
}
```

### 返り値ありの `Task<T>`

返り値があるタスクのとき、返り値の型は `Task<T>` となります。
以下は、タスクを作成して起動し、その結果を `task.Result` で取得する例です。

```cs
class StartTaskExample
{
    static void Main(string[] args)
    {
        const string url = "https://example.com";

        // タスクの作成と起動
        Task<string> task = Task.Run(() =>
            {
                Console.WriteLine($"[*] Downloading {url}");
                return "200 OK";
            });

        // タスクが終了するまで待機
        task.Wait();
        // => [*] Downloading https://example.com

        // タスクの結果を取得
        Console.WriteLine($"result={task.Result}");
        // => result=200 OK
    }
}
```

注意点として、タスクの完了まで待機する `task.Wait()` の前に、`task.Result` で結果を取得しようとするとエラーになります。

<br>

### ThreadPool.QueueUserWorkItem

ThreadPoolのAPIを直接呼び出すときは、ThreadPool#QueueUserWorkItemメソッドを使用します。
ただし、上記で紹介したTask.Runの方が直感的に定義できるため、Task.Runを使うことをおすすめします。

```cs
using System;
using System.Threading;

class StartThreadPoolExample
{
    public static void Main()
    {
        // スレッドプールを起動
        ThreadPool.QueueUserWorkItem(Download, "https://example.com");

        Console.WriteLine("Press Enter to terminate!");
        Console.ReadLine();
    }

    // 並列化したい処理をメソッドにする
    private static void Download(object? arg)
    {
        string url = "";
        if (arg is not null)
        {
            url = (string)arg;
        }
        Console.WriteLine($"[*] Downloading {url}");
    }
}
```


以上です。
