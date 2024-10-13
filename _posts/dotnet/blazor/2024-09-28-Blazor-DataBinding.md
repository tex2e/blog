---
layout:        post
title:         "[Blazor] 一方向と双方向データバインディング"
date:          2024-09-28
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

ASP.NET Core Blazorにおけるデータバインディング（クライアントとサーバ側のデータのやり取りの方法）について説明します。

### 一方向データバインディング

一方向データバインディングは、サーバ側からクライアント側に一方的に変数の値を埋め込むことです。
`@code` 内で定義したメンバーの値が、htmlの「@」から始まる変数名に反映されます。

```csharp
@page "/onewaydatabinding"

<h3>一方向データバインディング</h3>
<p>@CurrentTime</p>

@code
{
    private string CurrentTime = $"現在の時刻は {DateTime.Now} です。";
}
```

### OnInitializedによる初期化

一方向データバインディングの変数の初期化は、OnInitialized() メソッド内でも行うことができます。
OnInitialized() メソッドはRazorの描画のライフサイクルにおけるコンポーネントの初期化時にのみ呼び出されるメソッドです。

```csharp
@page "/onewaydatabinding2"

<h3>一方向データバインディング（OnInitializedによる初期化）</h3>
<p>@CurrentTime</p>

@code
{
    private string CurrentTime = "";

    protected override void OnInitialized()
    {
        CurrentTime = $"現在の時刻は {DateTime.Now} です。";
    }
}
```

### 双方向データバインディング

画面から入力を受け付けて、それをメンバにバインドすることを、双方向データバインディングと呼びます。
双方向データバインディングでは、入力するHTMLのフィールドに対して `@bind` などの属性を付けて、その引数にメンバの変数名を指定することで、画面のロジック間の双方向のデータのやり取りを実現することができます。

```csharp
@page "/twowaydatabinding"
@rendermode InteractiveServer

<h3>双方向データバインディング</h3>

<input type="text" @bind="Name" @bind:event="oninput" placeholder="名前を入力">
<p>こんにちは、@(Name)さん</p>

@code
{
    private string Name { get; set; } = "名無し";
}
```

以上です。


### 参考資料

- [tex2e/BlazorSample: Blazorの検証環境](https://github.com/tex2e/BlazorSample)
