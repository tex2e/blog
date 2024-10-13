---
layout:        post
title:         "[Blazor] プログラムで画面遷移する (NavigationManager)"
date:          2024-10-11
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

ASP.NET Core Blazorのプログラム側で指定したURLに画面遷移するには、NavigationManage#NavigateTo(URL) メソッドを使います。
なお、利用するためには、まず NavigationManager を依存注入 (DI) しておく必要があります。

### プログラムによる画面遷移

```csharp
@page "/NavigationManager"
@rendermode InteractiveServer
@inject NavigationManager navigationManager

<input type="button" @onclick="buttonClick" value="メニューに戻る" />

@code
{
    private void buttonClick()
    {
        navigationManager.NavigateTo("/");
    }
}
```

以上です。


### 参考資料

- [tex2e/BlazorSample: Blazorの検証環境](https://github.com/tex2e/BlazorSample)
