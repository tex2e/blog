---
layout:        post
title:         "[C#] 依存注入のためのMS.DIコンテナの生存管理 (Transient/Singleton/Scoped)"
date:          2024-10-14
category:      Dotnet
cover:         /assets/cover14.jpg
redirect_from: /c%23/MSDI-container-lifetime-management
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

MS.DI (Microsoft.Extensions.DependencyInjection) を使って依存を注入するときに選ぶことができる3種類のスコープについて説明します。

### スコープの種類

MS.DIがサポートするスコープ（生存管理）には以下があります。

- **Transient** (短命) : 生成されたオブジェクトはコンテナ (ServiceProvider) によって管理され、破棄される。
- **Singleton** (シングルトン) : コンテナ (ServiceProvider) が生存している間は、そこで生成されたオブジェクトも生存し続ける
- **Scoped** (スコープ指定) : コンテナ (ServiceProvider) の CreateScope メソッドで作成したスコープ範囲内であれば、生成されたオブジェクトが再利用される

### スコープの指定方法

MS.DIコンテナにサービスを登録するときは、.Add〜 メソッドを使って、インターフェースとそれを実装したクラスを定義していきます。
.Add〜 のメソッド名の部分でスコープを指定することができます。

- `.AddTransient<MyInterface, MyClass>()` : 短命なサービスを登録する。毎回新しいインスタンスが生成される。
- `.AddSingleton<MyInterface, MyClass>()` : シングルトンなサービスを登録する。初回のみ新しいインスタンスが生成され、以降は再利用される。
- `.AddScoped<MyInterface, MyClass>()` : スコープ指定のサービスを登録する。スコープが異なるたびに初回のみ新しいインスタンスが生成され、以降は再利用される。

### サンプル

以下はインスタンス化したときに GUID が採番されるクラスを、それぞれのスコープで登録・インスタンス化したときに、どのように GUID が変化していくかを確認するためのプログラムです。

ServiceLifetimeReporter.cs（注入された依存の内容を出力するクラス）：

```csharp
namespace TestConsole;

internal sealed class ServiceLifetimeReporter(
    IExampleTransientService transientService,
    IExampleScopedService scopedService,
    IExampleSingletonService singletonService)
{

    public void ReportServiceLifetimeDetails(string lifetimeDetails)
    {
        Console.WriteLine(lifetimeDetails);

        LogService(transientService, "Always different");
        LogService(scopedService, "Changes only with lifetime");
        LogService(singletonService, "Always the same");
    }

    private static void LogService<T>(T service, string message)
        where T : IReportServiceLifetime
    {
        // クラス名、採番されたGUID、コメント を出力する
        Console.WriteLine($"    {typeof(T).Name,-30}: {service.Id} ({message})");
    }
}
```

IExampleScopedService.cs（スコープ付きサービスのインタフェース）：

```csharp
namespace TestConsole;
public interface IExampleScopedService : IReportServiceLifetime {}
```

IExampleSingletonService.cs（シングルトンなサービスのインタフェース）：

```csharp
namespace TestConsole;
public interface IExampleSingletonService : IReportServiceLifetime {}
```

IExampleTransientService.cs（短命なサービスのインタフェース）：

```csharp
namespace TestConsole;
public interface IExampleTransientService : IReportServiceLifetime {}
```

ExampleScopedService.cs（スコープ付きサービスの実装）：

```csharp
namespace TestConsole;
internal sealed class ExampleScopedService : IExampleScopedService
{
    Guid IReportServiceLifetime.Id { get; } = Guid.NewGuid();
}
```

ExampleSingletonService.cs（シングルトンなサービスの実装）：

```csharp
namespace TestConsole;
internal sealed class ExampleSingletonService : IExampleSingletonService
{
    Guid IReportServiceLifetime.Id { get; } = Guid.NewGuid();
}
```

ExampleTransientService.cs（短命なサービスの実装）：

```csharp
namespace TestConsole;
internal sealed class ExampleTransientService : IExampleTransientService
{
    Guid IReportServiceLifetime.Id { get; } = Guid.NewGuid();
}
```

IReportServiceLifetime.cs（サービス共通のインターフェイス）：

```csharp
namespace TestConsole;
public interface IReportServiceLifetime
{
    Guid Id { get; }
}
```

Program.cs（プログラムのエントリーポイント）：

```csharp
using Microsoft.Extensions.DependencyInjection;
using TestConsole;

// サービスの登録
var services = new ServiceCollection();
services.AddTransient<IExampleTransientService, ExampleTransientService>();
services.AddScoped<IExampleScopedService, ExampleScopedService>();
services.AddSingleton<IExampleSingletonService, ExampleSingletonService>();
// ServiceLifetimeReporter は、IExampleTransientService と IExampleScopedService と 
//   IExampleSingletonService の3つを引数にとるコンストラクタを持つ。
services.AddTransient<ServiceLifetimeReporter>();

// DIコンテナの作成
IServiceProvider container = services.BuildServiceProvider(validateScopes: true);

// スコープ1の作成
using (IServiceScope serviceScope = container.CreateScope())
{
    // インスタンスの生成（1回目)
    ServiceLifetimeReporter logger =
        serviceScope.ServiceProvider.GetRequiredService<ServiceLifetimeReporter>();
    logger.ReportServiceLifetimeDetails("Lifetime 1: Call 1:");
    // インスタンスの生成（2回目)
    ServiceLifetimeReporter logger2 =
        serviceScope.ServiceProvider.GetRequiredService<ServiceLifetimeReporter>();
    logger2.ReportServiceLifetimeDetails("Lifetime 1: Call 2:");
}

Console.WriteLine("---");

// スコープ2の作成
using (IServiceScope serviceScope = container.CreateScope())
{
    // インスタンスの生成（1回目)
    ServiceLifetimeReporter logger =
        serviceScope.ServiceProvider.GetRequiredService<ServiceLifetimeReporter>();
    logger.ReportServiceLifetimeDetails("Lifetime 2: Call 1:");
    // インスタンスの生成（2回目)
    ServiceLifetimeReporter logger2 =
        serviceScope.ServiceProvider.GetRequiredService<ServiceLifetimeReporter>();
    logger2.ReportServiceLifetimeDetails("Lifetime 2: Call 2:");
}
```

出力結果：

```console
Lifetime 1: Call 1:
    IExampleTransientService      : 4312228b-eb61-4419-bd64-66014fa63532 (Always different)
    IExampleScopedService         : 0c84eda7-943b-4f77-b84b-ed760c5b0259 (Changes only with lifetime)
    IExampleSingletonService      : b1fa29da-41f9-4f8d-ad84-88e100f5af2c (Always the same)
Lifetime 1: Call 2:
    IExampleTransientService      : 415e95d3-5c1b-4486-b61d-97f3c7539cf6 (Always different)
    IExampleScopedService         : 0c84eda7-943b-4f77-b84b-ed760c5b0259 (Changes only with lifetime)
    IExampleSingletonService      : b1fa29da-41f9-4f8d-ad84-88e100f5af2c (Always the same)
---
Lifetime 2: Call 1:
    IExampleTransientService      : fd2f8e3d-a956-4ed5-bf4d-6228d5f099b4 (Always different)
    IExampleScopedService         : bb476e49-9816-4a32-98d2-0723f8a9ecf1 (Changes only with lifetime)
    IExampleSingletonService      : b1fa29da-41f9-4f8d-ad84-88e100f5af2c (Always the same)
Lifetime 2: Call 2:
    IExampleTransientService      : a8f2095d-6d88-40d7-882d-94438755520b (Always different)
    IExampleScopedService         : bb476e49-9816-4a32-98d2-0723f8a9ecf1 (Changes only with lifetime)
    IExampleSingletonService      : b1fa29da-41f9-4f8d-ad84-88e100f5af2c (Always the same)
```

出力結果から次のことが確認できます。

- AddTransient で登録したサービス IExampleTransientService は、毎回異なるGUIDになっている
- AddScoped で登録したサービス IExampleScopedService は、スコープの範囲内で同じGUIDになっている
- AddSingleton で登録したサービス IExampleSingletonService は、常に同じGUIDになっている

以上です。


### 参考資料

- [Use dependency injection - .NET \| Microsoft Learn](https://learn.microsoft.com/en-us/dotnet/core/extensions/dependency-injection-usage)
