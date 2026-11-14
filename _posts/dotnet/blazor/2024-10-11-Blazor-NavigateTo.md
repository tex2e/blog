---
layout:        post
title:         "[Blazor] プログラムで画面遷移する (NavigationManager)"
type:          How-To
description:   "ASP.NET Core BlazorでNavigationManagerを依存注入し、NavigateToメソッドを呼び出してプログラム側から指定URLへ画面遷移させる方法を解説します。"
tags:          [dotnet, csharp, blazor, routing, navigation]
status:        stable
stale_after:   2027-10-11T00:00:00Z
generated:
  by:          human:tex2e
  at:          2024-10-11T23:23:54Z
sources:
  - id:        ref-1
    resource:  https://github.com/tex2e/BlazorSample
    title:     "tex2e/BlazorSample: Blazorの検証環境"
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
