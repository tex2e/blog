---
layout:        post
title:         "[C#] Workerを使ってサービスを実装する"
date:          2024-10-18
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

C#の Worker を使ってサービスを実装する方法について説明します。


### Workerプロジェクトの作成

現在のフォルダに Worker サービスのテンプレートを生成します。

```
dotnet new worker
```

### サービスの実装

Program.cs（プログラムのエントリーポイント）：

```csharp
namespace TestWorker;

var builder = Host.CreateApplicationBuilder(args);
// Workerをサービスとして登録する
builder.Services.AddHostedService<Worker>();

var host = builder.Build();
host.Run();
```

Worker.cs（サービスの実装）：

```csharp
namespace TestWorker;

public class Worker : BackgroundService
{
    private readonly ILogger<Worker> _logger;

    public Worker(ILogger<Worker> logger)
    {
        _logger = logger;
    }

    // サービス実行時に呼び出されるメソッド
    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        while (!stoppingToken.IsCancellationRequested)
        {
            // ここでサービスで行いたい処理を実装します
            _logger.LogInformation("Worker running at: {time}", DateTimeOffset.Now);
            await Task.Delay(1000, stoppingToken);
        }
    }
}
```

このプログラムを実行すると、1秒ごとにログにメッセージを書き込む処理が停止するまで続きます。

```console
info: TestWorker.Worker[0]
      Worker running at: 10/14/2024 15:53:39 +09:00
info: TestWorker.Worker[0]
      Worker running at: 10/14/2024 15:53:40 +09:00
info: TestWorker.Worker[0]
      Worker running at: 10/14/2024 15:53:41 +09:00
```

この後は、サービスを起動させたいOSごとに、追加のパッケージのインストールと、サービスインストール用の資材の作成が必要になります。
詳細は以下のページを参考にしてください。

- Windows (sc.exe; サービスコントローラ)
    - [BackgroundService を使って Windows サービスを作成する - .NET \| Microsoft Learn](https://learn.microsoft.com/ja-jp/dotnet/core/extensions/windows-service)
- Linux (systemd)
    - [How to deploy .NET apps as systemd services using containers \| Red Hat Developer](https://developers.redhat.com/articles/2023/01/17/how-deploy-net-apps-systemd-services-using-containers#)

以上です。


### 参考資料

- [BackgroundService を使って Windows サービスを作成する - .NET \| Microsoft Learn](https://learn.microsoft.com/ja-jp/dotnet/core/extensions/windows-service)
