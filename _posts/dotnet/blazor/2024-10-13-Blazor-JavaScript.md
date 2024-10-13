---
layout:        post
title:         "[Blazor] イベントハンドラでJavaScriptを実行する"
date:          2024-10-13
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

ASP.NET Core Blazorでボタン押下時に任意のJavaScriptを実行する方法について説明します。

### JavaScript呼び出し

JavaScriptを呼び出すには、IJSRuntime を依存注入し、そのインスタンス（以下の例では _JSRuntime）メソッドである InvokeAsync を使います。
InvokeAsync メソッドの第1引数に呼び出すJSの関数名、第2引数にJSの関数に渡す引数（複数あるときは配列）を指定します。
第1引数のJSの関数名には `"インスタンス名.メソッド名"` の形式も指定可能です。この場合はJavaScript側では `window.インスタンス名.メソッド名` が呼び出されます。

```csharp
@page "/JavaScriptConfirm"
@rendermode InteractiveServer
@inject IJSRuntime _JSRuntime

<button @onclick="ScriptConfirm">確定</button>
<p>@Message</p>

@code
{
    private string Message { get; set; } = "";

    private async Task ScriptConfirm()
    {
        // JavaScriptで「confirm("実行します。よろしいですか？")」を実行する
        var res = await _JSRuntime.InvokeAsync<bool>("confirm", "実行します。よろしいですか？");
        if (res)
        {
            Message = "起動しました。";
        }
        else
        {
            Message = "キャンセルしました。";
        }
    }
}
```

以上です。


### 参考資料

- [JSRuntime.InvokeAsync メソッド (Microsoft.JSInterop) \| Microsoft Learn](https://learn.microsoft.com/ja-jp/dotnet/api/microsoft.jsinterop.jsruntime.invokeasync?view=aspnetcore-8.0#microsoft-jsinterop-jsruntime-invokeasync-1%28system-string-system-object%28%29%29)
- [tex2e/BlazorSample: Blazorの検証環境](https://github.com/tex2e/BlazorSample)
