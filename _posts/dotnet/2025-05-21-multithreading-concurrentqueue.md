---
layout:        post
title:         "[C#] マルチスレッド処理：スレッドセーフなキュー (ConcurrentQueue)"
date:          2025-05-21
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

マルチスレッド処理におけるデザインパターンの一つであるProducer-ConsumerパターンはConcurrentQueue（スレッドセーフなキュー）を使えば簡単に実装できます。
ConcurrentQueueはメッセージキューのように動作するオブジェクトとして利用できます。

## ConcurrentQueue

ConcurrentQueueクラスは、キューに値を入れるときはEnqueueで行い、TryDequeueまたはTryPeekでキューから値を取得・確認することができます。

```cs
using System;
using System.Threading;
using System.Collections.Concurrent;

class StartThreadPoolExample
{
    private static ConcurrentQueue<string> queue = new();

    public static void Main()
    {
        // 複数タスク経由でスレッドセーフなキューに登録
        Task taskEnq1 = Task.Run(() => queue.Enqueue("start job 1"));
        Task taskEnq2 = Task.Run(() => queue.Enqueue("start job 2"));
        Task taskEnq3 = Task.Run(() => queue.Enqueue("start job 3"));
        Task taskEnq4 = Task.Run(() => queue.Enqueue("start job 4"));
        Task taskEnq5 = Task.Run(() => queue.Enqueue("start job 5"));
        Task taskEnq6 = Task.Run(() => queue.Enqueue("start job 6"));
        Task taskEnq7 = Task.Run(() => queue.Enqueue("start job 7"));
        Task taskEnq8 = Task.Run(() => queue.Enqueue("start job 8"));
        Task taskEnq9 = Task.Run(() => queue.Enqueue("start job 9"));

        // キューから3個メッセージを取得できるまでループする処理
        void action()
        {
            int count = 0;
            string? localValue;
            while (queue.TryDequeue(out localValue))
            {
                count += 1;
                Console.WriteLine($"Dequeue message: {localValue}");
                // Task.Delay(100).Wait();
                if (count >= 3) break;
            }
        }
        // 複数タスクでスレッドセーフなキューから取得
        Task[] tasksDeq = new Task[3];
        tasksDeq[0] = Task.Run(action);
        tasksDeq[1] = Task.Run(action);
        tasksDeq[2] = Task.Run(action);

        // 全てのタスクが完了するまで待機
        Task.WaitAll(tasksDeq);
    }
}
```

注意点として、並行プログラミングではキューから値を取り出すときに null が返ってくる可能性がある点です。
例えば、Queueのカウント（Count）を調べる方法を使ったとき、調べた時点ではキューの中に要素が1以上存在していても、キューから取り出すタイミングでは存在しない場合があります。
このような問題は TOCTOU（Time Of Check to Time Of Use）と呼ばれ、システムの脆弱性にもつながります。
TryPeekした時点では存在したけど、TryDequeueするときにはnullになってしまうこともあるため、確認と取得が別々になるような実装は注意が必要です。

以上です。
