---
layout:        post
title:         "[Blazor] UIコンポーネントのタグ内に任意のHTMLを描画させる"
date:          2024-10-07
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

ASP.NET Core Blazorで作成した自作のUIコンポーネントのタグ内に任意のHTMLを描画させる方法について説明します。

### UIコンポーネントのタグ内に任意のHTMLを描画させる

UIコンポーネントの呼び出し元から任意のHTMLを受け取るには、RenderFragment 型のメンバ変数を public かつ \[Parameter\] アノテーションを付ける必要があります。
この RenderFragment 型のメンバ変数は、そのまま Razor ページの中に埋め込むことができます。

Components/Pages/Sample.razor：

```csharp
@page "/RenderFragment"

@using BlazorSample.Components.Shared

<MyPanel Title="部品1">
    1つ目の文章
    <hr />
    2つ目の文章
</MyPanel>

<MyPanel Title="部品2">
</MyPanel>
```

Components/Shared/MyPanel.razor

```csharp
<div class="alert alert-success" role="alert">
    <h4 class="alert-heading">@Title</h4>
    @if (ChildContent != null)
    {
        <p>@ChildContent</p>
    }
</div>

@code
{
    [Parameter]
    public string Title { get; set; } = "";

    [Parameter]
    public RenderFragment? ChildContent { get; set; }
}
```


### UIコンポーネントのタグ内に複数のHTMLを描画させる

UIコンポーネントの呼び出し元から任意のHTMLを複数個受け取るには、複数の RenderFragment 型のメンバ変数を public かつ \[Parameter\] アノテーションを付けることで引数として受け取ることができます。

Components/Pages/Sample.razor：

```csharp
@page "/MultipleRenderFragment"

@using BlazorSample.Components.Shared

<MyPanelMultipleFragment Title="テストタイトル">
    <ChildContent1>
        1つ目の文章
    </ChildContent1>
    <ChildContent2>
        2つ目の文章
    </ChildContent2>
</MyPanelMultipleFragment>

```

Components/Shared/MyPanelMultipleFragment.razor

```csharp
<div class="alert alert-success" role="alert">
    <h4 class="alert-heading">@Title</h4>
    <p>@ChildContent1</p>
    <hr />
    <p>@ChildContent2</p>
</div>

@code
{
    [Parameter]
    public string Title { get; set; } = "";

    [Parameter]
    public RenderFragment? ChildContent1 { get; set; }

    [Parameter]
    public RenderFragment? ChildContent2 { get; set; }
}
```

以上です。


### 参考資料

- [tex2e/BlazorSample: Blazorの検証環境](https://github.com/tex2e/BlazorSample)
