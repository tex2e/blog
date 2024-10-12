---
layout:        post
title:         "[Blazor] セッションの読み書きをする"
date:          2024-10-12
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

ASP.NET Core Blazorでセッションを使う方法について説明します。

### セッションにデータを保存する

ProtectedBrowserStorage はブラウザが終了するまでデータを保持し続けるクラスを提供します。
つまり、画面遷移しても画面間で値を共有するセッションを利用することができます。

```csharp
@page "/Session"
@rendermode InteractiveServer
@inject Microsoft.AspNetCore.Components.Server.ProtectedBrowserStorage.ProtectedSessionStorage storage
@inject NavigationManager navigationManager

<p>ユーザー名：@LastUserName</p>
<input type="text" @bind="UserName" />
<button @onclick="SaveUserName">保存</button>

@code
{
    private string? LastUserName { get; set; }

    private string? UserName { get; set; }

    // ブラウザのDOMの更新が完了した後に実行されるメソッド
    protected override async Task OnAfterRenderAsync(bool firstRender)
    {
        // セッションからユーザ名を取得する
        var result = await storage.GetAsync<string>("Session_UserName");
        // セッションのユーザ名が取得できないときはデフォルト値を使用する
        LastUserName = result.Success ? result.Value : "（ゲスト）";
        if (firstRender)
        {
            // 初回レンダリングのみ画面を再描画する
            this.StateHasChanged();
        }
        Console.WriteLine($"Get UserName: {LastUserName}");
    }

    private async Task SaveUserName()
    {
        if (UserName != null)
        {
            LastUserName = UserName;
            // 画面のユーザ名の入力値をセッションに保存する
            await storage.SetAsync("Session_UserName", LastUserName);
            Console.WriteLine($"Save UserName: {LastUserName}");
        }
    }
}

```

以上です。


### 参考資料

- [tex2e/BlazorSample: Blazorの検証環境](https://github.com/tex2e/BlazorSample)
