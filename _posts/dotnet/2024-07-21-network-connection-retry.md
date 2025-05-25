---
layout:        post
title:         "[C#] ネットワーク通信失敗時に自動でリトライする仕組みを実装する"
date:          2024-07-21
category:      Dotnet
cover:         /assets/cover14.jpg
redirect_from: /c%23/network-connection-retry
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

C# でネットワーク通信失敗時に自動でリトライする仕組みを実装する方法について説明します。

以下の例では、FetchJsonData() メソッドで HTTP リクエスト通信が発生するものと仮定し、実際には例外「HttpRequestException」が発生したときに、一定時間待機してから再接続を試みるように実装しています。
また、接続サーバに対して過負荷にならないように、失敗回数が増えるごとに待機時間も増えるようにしています。

```csharp
using System.Net;

// ...クラス定義等省略...

public static void Main()
{
    Task.Run(FetchJsonDataWithRetry).Wait();
}

public static async void FetchJsonDataWithRetry()
{
    const int DelayMilliseconds = 1000;
    const int maxTryCount = 3;
    int tryCount = 0;
    bool success = false;

    try
    {
        do
        {
            try
            {
                Console.WriteLine("データ取得中");
                await FetchJsonData();
                success = true;
                break;
            }
            catch (HttpRequestException ex) when (ex.StatusCode == HttpStatusCode.RequestTimeout)
            {
                tryCount++;
                int waitTime = DelayMilliseconds * tryCount;
                Console.WriteLine($"通信時のタイムアウト発生。{waitTime}ミリ秒待機します。");
                Task.Delay(waitTime).Wait();
            }
        } while (tryCount < maxTryCount);
    }
    finally {
        if (success)
            Console.WriteLine("処理が成功しました。");
        else
            Console.WriteLine("処理が失敗しました。");
    }
}

// HTTP通信をシミュレーションする関数
private static async Task<string> FetchJsonData()
{
    // 通信が成功したとき
    // return await Task.FromResult("{\"result\":\"ok!\"}");
    // 通信が失敗したとき
    throw await Task.FromResult(
        new HttpRequestException("Timeout", null, HttpStatusCode.RequestTimeout));
}
```

実行時の出力例：

```output
データ取得中
通信時のタイムアウト発生。1000ミリ秒待機します。
データ取得中
通信時のタイムアウト発生。2000ミリ秒待機します。
データ取得中
通信時のタイムアウト発生。3000ミリ秒待機します。
処理が失敗しました。
```

以上です。
