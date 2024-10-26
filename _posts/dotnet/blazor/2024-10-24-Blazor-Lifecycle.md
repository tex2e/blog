---
layout:        post
title:         "[Blazor] ライフサイクルで実行されるメソッド一覧"
date:          2024-10-24
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

ASP.NET Core Blazorにおけるライフサイクルで実行されるメソッド一覧について説明します。
ライフサイクルで実行されるのは、以下の3種類×2のメソッドがあります。

- UIコンポーネントが読み込まれるときに呼び出されるメソッド
    - `protected override void OnInitialized()` （同期実行）
    - `protected override async Task OnInitializedAsync()` （非同期実行）
- UIコンポーネントにバインドされているパラメータが更新されるたびに呼び出される
    - `protected override void OnParametersSet()` （同期実行）
    - `protected override async Task OnParametersSetAsync()` （非同期実行）
- UIコンポーネントの描画が終わったときに呼び出される
    - `protected override void OnAfterRender(bool firstRender)` （同期実行）
    - `protected override async Task OnAfterRenderAsync(bool firstRender)` （非同期実行）

以下は上記の6個のメソッドをオーバーライドして、イベントごとに呼び出される例です。

```csharp
@page "/LifeCycle/{Id:int}"
@rendermode InteractiveServer

<h3>Blazorのライフサイクル</h3>

<button @onclick="@(() => Message.Add("Clicked!"))">ボタン</button>

<div>
    @foreach (var msg in Message)
    {
        <p>@msg</p>
    }
</div>

@code
{
    [Parameter]
    public int Id { get; set; }

    private List<string> Message = new();

    // UIコンポーネントが読み込まれるときに呼び出される
    protected override void OnInitialized()
    {
        Message.Add($"(1) Called OnInitialized");
    }

    // UIコンポーネントが読み込まれるときに呼び出される（非同期実行）
    protected override async Task OnInitializedAsync()
    {
        await Task.Yield();
        Message.Add($"(2) Called OnInitializedAsync");
    }

    // UIコンポーネントにバインドされているパラメータが更新されるたびに呼び出される
    protected override void OnParametersSet()
    {
        Message.Add($"(3) Called OnParametersSet with {Id}");
    }

    // UIコンポーネントにバインドされているパラメータが更新されるたびに呼び出される（非同期実行）
    protected override async Task OnParametersSetAsync()
    {
        await Task.Yield();
        Message.Add($"(4) Called OnParametersSetAsync with {Id}");
    }

    // UIコンポーネントの描画が終わったときに呼び出される
    protected override void OnAfterRender(bool firstRender)
    {
        Message.Add($"(5) Called OnAfterRender with firstRender={firstRender}");
    }

    // UIコンポーネントの描画が終わったときに呼び出される（非同期実行）
    protected override async Task OnAfterRenderAsync(bool firstRender)
    {
        await Task.Yield();
        Message.Add($"(6) Called OnAfterRenderAsync with firstRender={firstRender}");
    }

}
```

以上です。


### 参考資料

- [ASP.NET Core Razor component lifecycle \| Microsoft Learn](https://learn.microsoft.com/en-us/aspnet/core/blazor/components/lifecycle?view=aspnetcore-8.0)
