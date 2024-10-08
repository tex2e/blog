---
layout:        post
title:         "[Blazor] Razorページ内でforeach文を使う"
date:          2024-10-03
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

ASP.NET Core BlazorのRazor内でforeach文を使う方法について説明します。

### foreachで一覧を表示する

Razorページの中でforeachによる繰り返しをするには `@foreach (式) { ... }` を使います。
以下は商品の一覧が格納されている変数 products をforeachで表示する例です。

Components/Pages/Sample.razor：

```csharp
@page "/foreach"
@rendermode InteractiveServer

@using BlazorSample.Models

<table>
    <thead>
        <tr>
            <th>ID</th>
            <th>商品名</th>
            <th>選択</th>
        </tr>
    </thead>
    <tbody>
        @* ここのforeachで一覧を表示します *@
        @foreach (var product in products)
        {
            <tr>
                <td>@product.Id</td>
                <td>@product.Name</td>
                <td><button @onclick="() => AddCart(product)">カードに追加</button></td>
            </tr>
        }
    </tbody>
</table>

<p>選択した商品名：@selectedProductName</p>

@code
{
    private List<Product> products = new List<Product>()
        {
            new Product() { Id = 1, Name = "Product1" },
            new Product() { Id = 2, Name = "Product2" },
            new Product() { Id = 3, Name = "Product3" },
        };

    private string selectedProductName = "";

    private void AddCart(Product product)
    {
        selectedProductName = product.Name;
    }
}
```

Models/Product.cs：

```csharp
namespace BlazorSample.Models
{
    public class Product
    {
        public int Id { get; set; }
        public string Name { get; set; } = "";
        public bool IsActive { get; set; } = true;
    }
}
```

`@` によるバインドを使うことで、構造体のメンバにアクセスすることができます。
また、`@onclick` によるイベントハンドラの引数に構造体を渡すことで、選択した商品を特定することができます。

以上です。


### 参考資料

- [tex2e/BlazorSample: Blazorの検証環境](https://github.com/tex2e/BlazorSample)
