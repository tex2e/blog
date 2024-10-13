---
layout:        post
title:         "[Blazor] ドロップダウンリストで双方向データバインディングする"
date:          2024-10-01
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

ASP.NET Core Blazorにおけるドロップダウンリスト (Drop Down List) を使ったデータバインディング（クライアントとサーバ側のデータのやり取りの方法）について説明します。

### ドロップダウンリストからデータを取得する

ドロップダウンリスト (selectタグ) の入力内容を `@code` のメンバー変数に反映するには、selectタグに `@bind` 属性を付けて、その引数に反映先の変数名を指定します。


```csharp
@page "/dropdownlist"
@rendermode InteractiveServer

<h3>ドロップダウンリストからデータを取得する</h3>

<select @bind="selectedKey">
    <option value="" selected hidden>選択してください</option>
    @foreach (var item in selectList)
    {
        <option value="@item.Value">@item.Key</option>
    }
</select>
<br /><br />
<p>選択した項目名：@(selectList.FirstOrDefault(x => x.Value == selectedKey).Key)</p>
<p>内容：@selectedKey</p>

@code
{
    private string selectedKey = "";
    Dictionary<string, string> selectList = new Dictionary<string, string>()
    {
        {"Red", "1"},
        {"Green", "2"},
        {"Blue", "3"},
    };
}
```


### ドロップダウンリストへデータを反映する

メンバ変数の内容をチェックボックスに反映させたい時は、selectタグに同様に `@bind` を指定することで、画面側に反映させることができます。

```csharp
<!-- 省略 -->

<select @bind="selectedKey" disabled>
    <option value="" selected hidden>選択してください</option>
    @foreach (var item in selectList)
    {
        <option value="@item.Value">@item.Key</option>
    }
</select>

<!-- 省略 -->
```

以上です。


### 参考資料

- [tex2e/BlazorSample: Blazorの検証環境](https://github.com/tex2e/BlazorSample)
