---
layout:        post
title:         "[Blazor] クリック時のイベントハンドラを設定する"
date:          2024-10-02
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

ASP.NET Core Blazorにクリック時のイベントハンドラの設定方法について説明します。

### クリック時のイベントハンドラを設定する

ボタン (buttonタグ) が押下されたタイミングで特定のメソッドを実行したいときは、buttonタグに `@onclick` 属性を付けて、その引数に実行したいメソッド名を指定します。

以下の例では、「カウントアップ」ボタンを押下すると、IncrementCount() メソッドが呼び出されて、カウントの表示が +1 ずつ増えていくプログラムです。

```csharp
@page "/button"
@rendermode InteractiveServer

<button @onclick="IncrementCount">カウントアップ</button>
<p>カウント：@Count</p>

@code
{
    private int Count { get; set; } = 0;

    private void IncrementCount()
    {
        Count++;
    }
}
```

### イベントハンドラに引数を渡す

1つのイベントハンドラの処理を、引数で分岐させたいときは、イベントハンドラに引数を渡して処理を制御することができます。
その場合、onclick属性に渡す引数は、まずラムダ式を渡してあげて、その中で実行したいイベントハンドラを定義します。

```csharp
@page "/eventhandlerwithargs"
@rendermode InteractiveServer

<button @onclick="@(e => SetMessage("こんにちは"))">メッセージ1表示</button>
<button @onclick="@(e => SetMessage("Hello"))">メッセージ2表示</button>
<button @onclick="@(e => SetMessage("你好"))">メッセージ3表示</button>

<p>メッセージ：@Message</p>

@code
{
    private string Message { get; set; } = "";

    private void SetMessage(string message)
    {
        Message = message;
    }
}
```

### 非同期でイベントハンドラを実行する

イベントハンドラに非同期メソッドを指定することもできます。
非同期の場合はメソッドの修飾子に async を付けます。

```csharp
@page "/asynceventhandler"
@rendermode InteractiveServer

<button @onclick="SetMessage">メッセージ表示</button>

<p>メッセージ：@Message</p>

@code
{
    private string Message { get; set; } = "";

    private async Task SetMessage()
    {
        Message = $"読み込み中... ({DateTime.Now})";
        await Task.Delay(3000);
        Message = $"読み込み完了！ ({DateTime.Now})";
    }
}
```

以上です。


### 参考資料

- [tex2e/BlazorSample: Blazorの検証環境](https://github.com/tex2e/BlazorSample)
