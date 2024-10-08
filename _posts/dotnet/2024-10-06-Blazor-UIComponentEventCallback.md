---
layout:        post
title:         "[Blazor] 自作UIコンポーネントにおけるイベントハンドラの設定方法"
date:          2024-10-06
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

ASP.NET Core Blazorで作成した自作のUIコンポーネント内で発生したイベントを、引数のイベントハンドラを経由して受け取り処理する方法について説明します。

### 自作UIコンポーネントから直接イベントを受け取る

自作のUIコンポーネントが、引数としてパラメータを受け取るには、publicなメンバー変数に `[Parameter]` アノテーションを付けます。
Parameterアノテーションがつけられたメンバー変数は、UIコンポーネントを呼び出すときに、HTML属性の形式で引数を与えることができます。
以下では、自作のUIコンポーネント MyButton に、引数 OnClickCallback でイベントハンドラを渡している例です。

Components/Pages/Sample.razor：

```csharp
@page "/UIComponentEventCallback"
@rendermode InteractiveServer

@using BlazorSample.Components.Shared

<MyButton Text="検索する" OnClickCallback="MyButton_Click" />
<MyLabel Text="@labelText" />

@code
{
    private string labelText { get; set; } = "ボタンをクリックしてください";

    private void MyButton_Click()
    {
        labelText = "ボタンが押されました";
    }
}
```

Components/Shared/MyButton.razor：

```csharp
<button @onclick="OnClickCallback" class="btn btn-primary">@Text</button>

@code
{
    [Parameter]
    public string Text { get; set; } = "";

    [Parameter]
    public EventCallback OnClickCallback { get; set; }
}
```

Components/Shared/MyLabel.razor：

```csharp
<span>@Text</span>

@code
{
    [Parameter]
    public string Text { get; set; } = "";
}
```

### 自作のUIコンポーネントがイベントを処理してからイベントを返す

自作のUIコンポーネントの呼び出し元にイベントを返す前に、まず自作のUIコンポーネントの中でイベントを処理したい場合があります。
そのときは、以下のように、自作UIコンポーネントで渡された引数のイベントハンドラをいきなり実行する代わりに、UIコンポーネント内のメソッドをイベントハンドラとし、そこで処理をし終わった後に、親から渡されたイベントハンドラを呼び出す、という流れにします。

以下は、ボタンを押されたら、UIコンポーネント内でボタンのCSSを変更してから、親から渡された引数 OnClickCallback イベントハンドラを実行している例です。

Components/Pages/Sample.razor：

```csharp
@page "/UIComponentEventFromCode"
@rendermode InteractiveServer

@using BlazorSample.Components.Shared

<MyButtonEventFromCode Text="検索する" OnClickCallback="MyButton_Click" />
<MyLabel Text="@labelText" />

@code
{
    private string labelText { get; set; } = "ボタンをクリックしてください";

    private void MyButton_Click()
    {
        labelText = "ボタンが押されました";
    }
}
```

Components/Shared/MyButtonEventFromCode.razor

```csharp
<button @onclick="OnButtonClicked" class="btn btn-primary @ButtonCss">@Text</button>

@code
{
    private string ButtonCss { get; set; } = "";

    [Parameter]
    public string Text { get; set; } = "";

    [Parameter]
    public EventCallback OnClickCallback { get; set; }

    private async Task OnButtonClicked()
    {
        // 子コンポーネント側での処理
        ButtonCss = "disabled";  // 2回連続で実行されないように、ボタンのリンク機能を無効化する

        // 呼び出し元から渡されたコールバック関数を呼び出す
        await OnClickCallback.InvokeAsync();
    }
}
```

以上です。


### 参考資料

- [tex2e/BlazorSample: Blazorの検証環境](https://github.com/tex2e/BlazorSample)
