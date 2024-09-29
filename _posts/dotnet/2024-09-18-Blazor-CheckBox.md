---
layout:        post
title:         "[Blazor] チェックボックスで双方向データバインディングする"
date:          2024-09-18
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

ASP.NET Core Blazorにおけるチェックボックス (Checkbox) を使ったデータバインディング（クライアントとサーバ側のデータのやり取りの方法）について説明します。

### チェックボックスからデータを取得する

チェックボックス (inputタグ、checkboxタイプ) の入力内容を `@code` のメンバー変数に反映するには、inputタグに `@bind` 属性を付けて、その引数に反映先の変数名を指定します。

```csharp
@page "/checkbox"
@rendermode InteractiveServer

<input id="mycheckbox" type="checkbox" @bind="isChecked" />
<label for="mycheckbox">添付資料の有無</label>
<p>@(isChecked ? "あり" : "なし")</p>

@code
{
    private bool isChecked { get; set; } = false;
}
```

### チェックボックスへデータを反映する

メンバ変数の内容をチェックボックスに反映させたい時は、同様に `@bind` を指定することで、画面側に反映させることができます。

```csharp
<!-- 省略 -->

<input id="mycheckbox2" type="checkbox" @bind="isChecked" disabled />
<label for="mycheckbox2">確認有無</label>

@code
{
    private bool isChecked { get; set; } = false;
}
```

以上です。
