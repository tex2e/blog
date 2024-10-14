---
layout:        post
title:         "[C#] MS.DIコンテナでデリゲートを用いたサービス登録"
date:          2024-10-15
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

MS.DI (Microsoft.Extensions.DependencyInjection) を使って依存を注入するときに、デリゲート (Delegate) を使うことでインスタンスの値を編集することができます。

以下のプログラムでは、ExampleService クラスが依存先である ExampleConfig クラス（設定値の情報を持つクラス）を参照するときに、ExampleConfig をデリゲートを使ってサービス登録する例です。

ExampleConfig.cs（設定値の情報を持つクラス）：

```csharp
namespace TestConsoleDelegate;
public class ExampleConfig
{
    public string ConfigPath { get; set; } = "";
}
```

IExampleService.cs（サービスのインターフェース）：

```csharp
namespace TestConsoleDelegate;
public interface IExampleService
{
    public string GetConfig();
}
```

ExampleService.cs（サービスの実装）：

```csharp
namespace TestConsoleDelegate;
public class ExampleService(ExampleConfig exampleConfig) : IExampleService
{
    public string GetConfig()
    {
        return exampleConfig.ConfigPath;
    }
}
```

Program.cs（プログラムのエントリーポイント）：

```csharp
using Microsoft.Extensions.DependencyInjection;
using TestConsoleDelegate;

// サービスの登録
var services = new ServiceCollection();
services.AddSingleton<ExampleConfig>(c => new ExampleConfig()
{
    ConfigPath = "/path/to/config"  // ここで設定値を修正できる
});
services.AddTransient<IExampleService, ExampleService>();

// DIコンテナの作成
IServiceProvider container = services.BuildServiceProvider();

// サービスの使用
var exampleService = container.GetRequiredService<IExampleService>();
Console.WriteLine(exampleService.GetConfig());
```

出力結果：

```console
$ dotnet run
/path/to/config
```

AddSingleton で常に同じインスタンスを返すように設定し、そのデリゲーションの中でインスタンスのプロパティを修正することで、設定値を注入することができます。

以上です。
