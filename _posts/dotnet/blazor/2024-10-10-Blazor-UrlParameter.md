---
layout:        post
title:         "[Blazor] URLパラメータを取得する"
date:          2024-10-10
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

ASP.NET Core BlazorでURLパラメータを取得する方法について説明します。


### URLパラメータの取得

URLに含まれるスラッシュ区切りの文字列（URLパラメータ）を取得するときは、`{変数名}` をルーティングの定義に含めます。
なお、そのときに指定するメンバ変数は `[Parameter]` アノテーションで定義されている必要があります。

```csharp
@page "/UrlParameter/{UserId}"
@page "/UrlParameter/{UserId}/{HistoryId}"

<p>ユーザーID：@UserId</p>
<p>履歴番号：@HistoryId</p>

@code
{
    [Parameter]
    public string UserId { get; set; } = "";

    [Parameter]
    public string HistoryId { get; set; } = "";
}
```


### URLパラメータの取得（型制約あり）

URLパラメータに型制約をつけることで、より入力を制限することができます。
例えば、整数しか受け取らないURLパラメータには `{変数名:int}` のように書くことができます。

```csharp
@page "/UrlParameter/Constraints/{UserId:int}"
@page "/UrlParameter/Constraints/{UserId:int}/{HistoryId:int}"

<p>ユーザーID：@UserId</p>
<p>履歴番号：@HistoryId</p>

@code
{
    [Parameter]
    public int UserId { get; set; }

    [Parameter]
    public int HistoryId { get; set; }
}
```


### URLパラメータの取得（入力チェックあり）

URLパラメータの入力を正規表現などでチェックすることもできます。
OnParametersSet メソッドは、パラメータが設定されたときに呼び出されるイベントハンドラで、この中でパラメータの値チェックをすることで、バリデーションをすることができます。

```csharp
@page "/UrlParameter/Validation/{UserId}"
@rendermode InteractiveServer

@using System.Text.RegularExpressions

<div class="@(ErrorMessages.Count == 0 ? "visually-hidden" : "")">
    <div class="alert alert-danger" role="alert">
        @foreach (string message in ErrorMessages)
        {
            <div>@message</div>
        }
    </div>
</div>

<p>ユーザーID：@UserId</p>

@code
{
    private List<string> ErrorMessages { get; set; } = new List<string>();

    [Parameter]
    public string UserId { get; set; } = "";

    protected override void OnParametersSet()
    {
        if (String.IsNullOrEmpty(UserId)
            || Regex.IsMatch(UserId, @"^[a-zA-Z]+[a-zA-Z0-9]*$") == false)
        {
            ErrorMessages.Add("不正なユーザーIDです！");
        }
    }
}
```


### URLパラメータの取得（全取得）

あまり使う機会はないですが、URLに含まれる以降の文字列をすべて取得することもできます。
URLパラメータで `{*変数名}` と書くことで、残りのすべての文字列とマッチし、その内容を変数に格納してくれます。

```csharp
@page "/UrlParameter/catch-all/{*PageParameters}"

<p>URLのパラメータ：@PageParameters</p>

@code
{
    [Parameter]
    public string PageParameters { get; set; } = "";
}
```


以上です。


### 参考資料

- [tex2e/BlazorSample: Blazorの検証環境](https://github.com/tex2e/BlazorSample)
