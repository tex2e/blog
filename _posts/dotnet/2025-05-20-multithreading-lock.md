---
layout:        post
title:         "[C#] マルチスレッド処理：lockによる変数へのアクセス排他制御"
date:          2025-05-20
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

マルチスレッド処理において、複数スレッドが同時に変数を読み書きすると、変数の値が壊れてしまいます。
この記事では、.NETではlockキーワードを使って、変数にアクセスできるスレッドを1つに制限する方法について説明します。

## lock

以下の例では、2個のスレッドを同時に起動させ、それぞれと共通の変数 `sum` を読み書きするときに lock でアクセス排他制御をする例です。
lockキーワードによって変数にアクセスできるスレッドを1つに制限できます。

```cs
class LockExample
{
    private static int sum;
    private static object _lock = new object();

    static void Main(string[] args)
    {
        Thread t1 = new Thread(() =>
        {
            for (int i = 0; i < 10000; i++)
            {
                lock (_lock)
                {
                    sum++;  // 計算結果に+1する
                }
            }
        });

        Thread t2 = new Thread(() =>
        {
            for (int i = 0; i < 10000; i++)
            {
                lock (_lock)
                {
                    sum++;  // 計算結果に+1する
                }
            }
        });

        // 2個のスレッドを並列で起動
        t1.Start();
        t2.Start();

        // 2個のスレッドが完了するまで待機
        t1.Join();
        t2.Join();

        // 合計結果出力
        Console.WriteLine("sum: " + sum);
        // => 20000
    }
}
```

注意点として、lockに使うオブジェクト（例：`_lock`）は任意のオブジェクトを指定できますが、プリミティブ型（int型などの値型）は指定できません。
int型からobject型にキャストすると（ボックス化すると）System.Objectインスタンス内部にラップされるため、lockするたびに毎回新しいインスタンスが作られてしまい、lockの同期が取れなくなってしまうからです。

補足ですが、キーワードlockは内部的にMonitorクラスを使用しています。
排他獲得の `Monitor.Enter(_lock)` と、排他解除の `Monitor.Exit(_lock)` でアクセス制御をする代わりに、C#ではlockキーワードを使うことでマルチスレッド環境での排他制御ができます。

以上です。
