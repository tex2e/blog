---
layout:        post
title:         "[Blazor] HTML属性の一括設定する（属性スプラッティング）"
date:          2024-10-05
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

ASP.NET Core BlazorのRazor内でHTML属性の一括設定する方法（属性スプラッティング）について説明します。

### HTML属性の一括設定する（属性スプラッティング）

Razorページ内の任意のHTMLタグに属性を付けたいときは、`@attributes` を使用します。
`@attributes` 属性の引数に Dictionary\<string, object\>型のメンバー変数を指定すると、そのメンバ変数が変化すると、画面側のHTMLの属性もそれに合わせて属性名と属性値がそれぞれ反映されます。

```csharp
@page "/attributes"
@rendermode InteractiveServer

<input type="text" @attributes="InputAttributes" />
<button @onclick="UpdateAttributes">属性変更</button>

@code
{
    private Dictionary<string, object> InputAttributes { get; set; } = new()
    {
        { "maxlength", "10" },
        { "placeholder", "Input placeholder text" },
        { "required", "required" },
        { "size", "50" }
    };

    private void UpdateAttributes()
    {
        InputAttributes = new()
        {
            { "maxlength", "15" },
            { "placeholder", "Input!!" },
            { "required", "required" },
            { "size", "75" }
        };
    }
}
```

以上です。


### 参考資料

- [tex2e/BlazorSample: Blazorの検証環境](https://github.com/tex2e/BlazorSample)
