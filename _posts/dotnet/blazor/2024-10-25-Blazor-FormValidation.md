---
layout:        post
title:         "[Blazor] EditFormによるフォームの入力検証チェック"
date:          2024-10-25
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

ASP.NET Core BlazorでEditFormを使ってフォームに入力された値の検証（バリデーション）を行う方法について説明します。

### モデルの定義

はじめに、フォームに入力した値を格納するモデルを作成します。
このとき、DataAnnotations を使って、各プロパティの必須項目や入力条件を設定します。

```csharp
using System.ComponentModel.DataAnnotations;

namespace BlazorSample.Models;

public class Product
{
    public int Id { get; set; }

    [Required(ErrorMessage = "名前は入力必須です")]
    public string Name { get; set; } = "";

    [Range(1, 1000, ErrorMessage = "値段は1円以上1000円以下を入力してください")]
    public decimal Price { get; set; }
}
```

例えば、Required は入力必須のプロパティを指定でき、Range は数値型のプロパティの下限と上限を指定することができます。

### ValidationSummaryによる入力エラー表示

EditFormタグを使うことで、入力内容とモデルを紐づけることができます。
EditFormタグのModel属性に格納先の変数を指定します。
EditForm内の入力フィールドである InputText や InputNumber などを配置します。

そして、EditForm内に **DataAnnotationsValidator** タグを配置することでデータアノテーションでモデルに設定したバリデーションが動作し、入力の検証が行われます。
検証の結果失敗した項目は、赤色になります。

さらに、検証時のエラー出力内容を表示させるために **ValidationSummary** タグを配置します。
ValidationSummary は EditForm 内の各入力項目でのエラー内容をまとめて表示するコンポーネントです。
入力エラーの一覧がリスト形式で表示されます。

```csharp
@page "/FormValidationSummary"
@rendermode InteractiveServer
@using BlazorSample.Models

<h3>BlazorForm</h3>

<p>@result</p>

<EditForm Model="product" OnValidSubmit="OnSubmit">
    <DataAnnotationsValidator />
    <ValidationSummary /> @* ここに入力時エラーが表示される *@
    <div>
        <div>名前</div>
        <InputText @bind-Value=product.Name></InputText>
    </div>
    <div>
        <div>価格</div>
        <InputNumber @bind-Value=product.Price></InputNumber>
    </div>
    <button type="submit">確定</button>
</EditForm>

@code
{
    public Product product { get; set; } = new();
    private string result = "";

    private void OnSubmit()
    {
        result = "Complete!";
    }
}
```

また、EditFormタグのOnValidSubmit属性に自作のメソッドを設定することで、submitボタンを押下して、全てのバリデーションに合格したときのみ実行されるハンドラを定義することができます。


### FormValidationMessageによる入力エラー表示

検証時のエラー出力内容を表示させるもう一つの方法として **ValidationMessage** タグがあります。
ValidationMessage は1コンポーネントに1エラーを表示するため、入力フィールドの近くに配置できるコンポーネントです。
入力項目に対応する入力エラーがそれぞれで1つ表示されます。

```csharp
@page "/FormValidationMessage"
@rendermode InteractiveServer
@using BlazorSample.Models

<h3>BlazorForm</h3>

<p>@result</p>

<EditForm Model="product" OnValidSubmit="OnSubmit">
    <DataAnnotationsValidator />
    <div>
        <div>名前</div>
        <InputText @bind-Value=product.Name></InputText>
        <ValidationMessage For="@(() => product.Name)" /> @* ここに入力時エラーが表示される *@
    </div>
    <div>
        <div>価格</div>
        <InputNumber @bind-Value=product.Price></InputNumber>
        <ValidationMessage For="@(() => product.Price)" /> @* ここに入力時エラーが表示される *@
    </div>
    <button type="submit">確定</button>
</EditForm>

@code
{
    public Product product { get; set; } = new();
    private string result = "";

    private void OnSubmit()
    {
        result = "Complete!";
    }
}
```

以上です。



### 参考資料

- [ValidationSummary クラス (Microsoft.AspNetCore.Components.Forms) \| Microsoft Learn](https://learn.microsoft.com/ja-jp/dotnet/api/microsoft.aspnetcore.components.forms.validationsummary?view=aspnetcore-8.0)
- [ValidationMessage\<TValue\> クラス (Microsoft.AspNetCore.Components.Forms) \| Microsoft Learn](https://learn.microsoft.com/ja-jp/dotnet/api/microsoft.aspnetcore.components.forms.validationmessage-1?view=aspnetcore-8.0)
- [DataAnnotationsValidator クラス (Microsoft.AspNetCore.Components.Forms) \| Microsoft Learn](https://learn.microsoft.com/ja-jp/dotnet/api/microsoft.aspnetcore.components.forms.dataannotationsvalidator?view=aspnetcore-8.0)
- [EditForm クラス (Microsoft.AspNetCore.Components.Forms) \| Microsoft Learn](https://learn.microsoft.com/ja-jp/dotnet/api/microsoft.aspnetcore.components.forms.editform?view=aspnetcore-8.0)
