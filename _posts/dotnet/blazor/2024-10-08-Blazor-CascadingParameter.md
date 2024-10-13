---
layout:        post
title:         "[Blazor] カスケーディングパラメータ (CascadingValue)"
date:          2024-10-08
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

ASP.NET Core Blazorで複数のUIコンポーネントをまたいでパラメータを渡す方法について説明します。

### 複数のUIコンポーネントをまたいでパラメータを渡す（カスケーディングパラメーター）

カスケーディングパラメーターとは、複数のUIコンポーネントをまたいでパラメータを渡す方法の一つです。
以下の例では、Message というカスケーディングパラメータを定義し、孫のUIコンポーネントがその値を参照できるようにする例です。

Components/Pages/Sample.razor：

```csharp
@page "/CascadingParameter"
@using BlazorSample.Components.Shared

<CascadingValue Value="Message">
    <MyCascadingParameterChild />
</CascadingValue>

@code
{
    private string Message { get; set; } = "Hello!";
}
```

Components/Shared/MyCascadingParameterChild.razor：

```csharp
@using BlazorSample.Components.Shared

<div class="cascading-parameter-child">
    <MyCascadingParameterGrandChild />
</div>
```

カスケーディングパラメータを受け取る側は `[CascadingParameter]` で宣言したメンバ変数に、渡された値が格納されます。

Components/Shared/MyCascadingParameterGrandChild.razor：

```csharp
<div class="alert alert-primary cascading-parameter-grandchild">
    <p>メッセージ：@MessageForGrandChild</p>
</div>

@code
{
    [CascadingParameter]
    public string MessageForGrandChild { get; set; } = "";
}
```



### 複数のUIコンポーネントをまたいでパラメータを渡す（名前付きカスケーディングパラメーター）

複数のカスケーディングパラメータを渡したい時は名前付きにする必要があります。
以下の例では、Message と Comment というカスケーディングパラメータを定義し、孫のUIコンポーネントが参照できるようにする例です。

Components/Pages/Sample.razor：

```csharp
@page "/CascadingParameterWithName"
@using BlazorSample.Components.Shared

<CascadingValue Value="Message" Name="MessageForGrandChild">
    <CascadingValue Value="Comment" Name="CommentForGrandChild">
        <MyCascadingParameterWithNameChild />
    </CascadingValue>
</CascadingValue>

@code
{
    private string Message { get; set; } = "Hello!";
    private string Comment { get; set; } = "It looks good to me!";
}
```

Components/Shared/MyCascadingParameterWithNameChild.razor

```csharp
@using BlazorSample.Components.Shared

<div class="cascading-parameter-child">
    <MyCascadingParameterWithNameGrandChild />
</div>
```

カスケーディングパラメータを受け取る側は `[CascadingParameter(Name=引数名)]` で宣言したメンバ変数に、渡された値が格納されます。

Components/Shared/MyCascadingParameterWithNameGrandChild.razor

```csharp
<div class="alert alert-primary cascading-parameter-grandchild">
    <p>メッセージ：@MessageForGrandChild</p>
    <p>コメント：@CommentForGrandChild</p>
</div>

@code
{
    [CascadingParameter(Name = "MessageForGrandChild")]
    public string MessageForGrandChild { get; set; } = "";

    [CascadingParameter(Name = "CommentForGrandChild")]
    public string CommentForGrandChild { get; set; } = "";
}
```

以上です。


### 参考資料

- [tex2e/BlazorSample: Blazorの検証環境](https://github.com/tex2e/BlazorSample)
