---
layout:        post
title:         "[Blazor] テキストボックスで双方向データバインディングする"
date:          2024-09-17
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

ASP.NET Core Blazorにおけるテキストボックス (Textbox) を使ったデータバインディング（クライアントとサーバ側のデータのやり取りの方法）について説明します。

### テキストボックスからデータを取得する

テキストボックス (inputタグ、textタイプ) の入力内容を `@code` のメンバー変数に反映するには、inputタグに `@bind` 属性を付けて、その引数に反映先の変数名を指定します。
デフォルトでは、テキストボックスからフォーカスが外れたとき（ロストフォーカス時）にメンバ変数に入力内容が反映されますが、どのタイミングで変数に反映させるかを `@bind:event` で指定することができ、「oninput」を指定することで、キーが押下されるたびに入力内容を即時メンバ変数に反映させられるようになります。

```csharp
@page "/textbox"
@rendermode InteractiveServer

<h4>1. ロストフォーカス時に反映される</h4>
<input type="text" @bind="Name1" placeholder="名前を入力" />
<p>こんにちは、@(Name1)さん</p>

<h4>2. 文字を入力すると即座に反映される</h4>
<input type="text" @bind="Name2" @bind:event="oninput" placeholder="名前を入力" />
<p>こんにちは、@(Name2)さん</p>

@code
{
    private string Name1 { get; set; } = "名無し";
    private string Name2 { get; set; } = "名無し";
}
```


### テキストボックスへデータを反映する

メンバ変数の内容をテキストボックスの入力欄に反映させたい時は、同様に `@bind` を指定することで、画面側に反映させることができます。

```csharp
<!-- 省略 -->

<input type="text" @bind="Name2" readonly />

@code
{
    private string Name1 { get; set; } = "名無し";
    private string Name2 { get; set; } = "名無し";
}
```

以上です。
