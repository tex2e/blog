---
layout:        post
title:         "[C#] プログラム実行時の構成 (Configuration) の読み込み"
date:          2024-10-16
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

プログラム実行時に構成 (Configuration) を読み込むときは、InMemory（メモリ上に設定情報を積んで実行する）ときや、JSONファイルに設定したものを読み込む方法など、いくつか種類があります。
ここでは、構成の読み込み方法と、設定値の検証方法について説明していきます。

### 1. InMemoryな構成の読み込み

設定ファイルは便利ですが、単体テストなどの自動テストとは相性が悪いです。
そのため、依存の注入によって単体テストのときはメモリ上で設定情報を積んで（In Memory な設定値で）実行したい場合があります。
MS公式が提供している Microsoft.Extensions.Configuration ライブラリをインストールして、ConfigurationBuilder を使うことで、この問題を解決することができます。

Program.cs：

```csharp
using Microsoft.Extensions.Configuration;

IConfiguration config = new ConfigurationBuilder()
    .AddInMemoryCollection(
        new Dictionary<string, string?>
        {
            ["Setting1"] = "value",
            ["MyOptions:Enabled"] = bool.TrueString,
        })
    .AddInMemoryCollection(
        new Dictionary<string, string?>
        {
            ["Setting2"] = "value2",
            ["MyOptions:Enabled"] = bool.FalseString,
        })
    .Build();

// Config名の大文字小文字は無視される
Console.WriteLine(config["setting1"]);  // => value
Console.WriteLine(config["setting2"]);  // => value2
// 最後に追加されたConfig値が優先される
Console.WriteLine(config["MyOptions:Enabled"]);  // => False
```


### 2. JSONファイルの構成の読み込み

Jsonファイルの設定を読み込むためには Microsoft.Extensions.Configuration.Json パッケージをnugetでインストールする必要があります。
さらに、.csproj ファイルの ItemGroup に appsettings.json に関する設定を追記します。

プロジェクト名.csproj：

```diff
 <Project Sdk="Microsoft.NET.Sdk">
 
   <PropertyGroup>
     <OutputType>Exe</OutputType>
     <TargetFramework>net8.0</TargetFramework>
     <ImplicitUsings>enable</ImplicitUsings>
     <Nullable>enable</Nullable>
   </PropertyGroup>
 
+  <ItemGroup>
+    <Content Include="appsettings.json">
+      <CopyToOutputDirectory>Always</CopyToOutputDirectory>
+    </Content>
+  </ItemGroup>
 
   <ItemGroup>
     <PackageReference Include="Microsoft.Extensions.Configuration" Version="8.0.0" />
+    <PackageReference Include="Microsoft.Extensions.Configuration.Json" Version="8.0.1" />
   </ItemGroup>
 
 </Project>
```

次に、csproj のプロジェクトファイルと同じフォルダに、appsettings.json を配置します。
appsettings.json の内容は以下のように JSON で書くことができます。

appsettings.json：

```json
{
    "Settings": {
        "Server": "example.com",
        "Database": "Northwind",
        "Port": 80
    }
}
```

必要なライブラリや設定ファイルが用意できたら、ConfigurationBuilder を使って JSON に記載した設定値を読み込むことができます。

Program.cs（プログラムのエントリーポイント）：

```csharp
using Microsoft.Extensions.Configuration;

IConfiguration config = new ConfigurationBuilder()
    .AddInMemoryCollection(
        new Dictionary<string, string?>
        {
            ["Settings:TestString"] = "value123",
            ["Settings:Enabled"] = bool.TrueString,
        })
    .AddJsonFile("appsettings.json")
    .Build();

// Settingsセクションの設定値の一覧を出力する
var settingsSection = config.GetSection("Settings");
foreach (var child in settingsSection.GetChildren())
{
    Console.WriteLine($"{child.Path} ({child.Key}) = {child.Value}");
}
// => Settings:Database (Database) = Northwind
// => Settings:Enabled (Enabled) = True
// => Settings:Port (Ports) = 80
// => Settings:Server (Server) = example.com
// => Settings:TestString (TestString) = value123

// 特定の設定値のみ取得する
Console.WriteLine(config["Settings:Database"]);
// => Northwind
```


### 3. 入力されたオプションの設定値を検証する

MS公式が提供している Microsoft.Extensions.Configuration.Binder ライブラリを追加でインストールすることで、ConfigurationBuilder で集めた設定値をクラスのインスタンスにバインドすることができます。
そしてバインド先のクラスのプロパティに、DataAnnotations による入力チェックを導入すれば、簡単に設定値のバリデーションチェックを行うことができるようになります。

ConfigDBSettings.cs（設定値のバインド先クラス）：

```csharp
namespace TestConfig;

using System.ComponentModel.DataAnnotations;

public sealed class ConfigDBSettings
{
    [RegularExpression(@"[a-zA-Z0-9]+")]
    public string Database { get; set; } = "";

    [RegularExpression(@"[a-zA-Z0-9.]+")]
    public string Server { get; set; } = "";

    [Range(1, 65535)]
    public int Port { get; set; }
}
```

Program.cs（プログラムのエントリーポイント）：

```csharp
using Microsoft.Extensions.Configuration;
using System.ComponentModel.DataAnnotations;
using TestConfig;

// 構成 (Configuration) の読み取り
IConfiguration config = new ConfigurationBuilder()
    .AddInMemoryCollection(
        new Dictionary<string, string?>
        {
            ["Settings:Port"] = "80",  // デフォルト値の設定
        })
    .AddJsonFile("appsettings.json")  // 設定ファイルから読み取り
    .Build();

// オプションクラスへ設定値を格納する
ConfigDBSettings configDBSettings = new();
config.GetSection("Settings")
    .Bind(configDBSettings);

// オプションの入力内容を検証する
var context = new ValidationContext(configDBSettings, serviceProvider: null, items: null);
var results = new List<ValidationResult>();
bool isValid = Validator.TryValidateObject(configDBSettings, context, results, true);
if (!isValid)
{
    throw new InvalidOperationException(results.First().ErrorMessage);
}

// オプションクラスから設定値を取得する
Console.WriteLine($"{configDBSettings.Database}");  // => Northwind
Console.WriteLine($"{configDBSettings.Server}");    // => example.com
Console.WriteLine($"{configDBSettings.Port}");      // => 80
```

バリデーションでエラーが発生するように、例えば、以下のように Port 番号を 100000 に設定してから再度実行してみます。

appsettings.json：

```json
{
    "Settings": {
        "Server": "example.com",
        "Database": "Northwind",
        "Port": 100000
    }
}
```

appsettings.json の設定値に不正な値が入っている状態で実行すると以下のようにエラーが発生します。

```console
$ dotnet run
Unhandled exception. System.InvalidOperationException: The field Port must be between 1 and 65535.
   at Program.<Main>$(String[] args) in /path/to/Program.cs:line 31
```

このように、Configuration.Binder を使うことでより安全に構成の設定値を取得することができるようになります。

以上です。


### 参考資料

- ConfigurationBuilder
    - [構成 - .NET \| Microsoft Learn](https://learn.microsoft.com/ja-jp/dotnet/core/extensions/configuration)
- System.ComponentModel.DataAnnotations
    - [RegularExpressionAttribute クラス (System.ComponentModel.DataAnnotations) \| Microsoft Learn](https://learn.microsoft.com/ja-jp/dotnet/api/system.componentmodel.dataannotations.regularexpressionattribute?view=net-8.0)
    - [RangeAttribute クラス (System.ComponentModel.DataAnnotations) \| Microsoft Learn](https://learn.microsoft.com/ja-jp/dotnet/api/system.componentmodel.dataannotations.rangeattribute?view=net-8.0)
