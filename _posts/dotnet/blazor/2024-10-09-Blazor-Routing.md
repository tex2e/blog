---
layout:        post
title:         "[Blazor] 複数のルーティングを同じページに遷移させる"
type:          How-To
description:   "ASP.NET Core BlazorのRazorページ先頭に複数の@pageディレクティブを記述し、異なる複数のURLルーティングを同一のページコンポーネントへ割り当てる方法を解説します。"
tags:          [dotnet, csharp, blazor, routing]
status:        stable
stale_after:   2027-10-11T00:00:00Z
generated:
  by:          human:tex2e
  at:          2024-10-11T22:59:47Z
date:          2024-10-09
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

ASP.NET Core Blazorで複数のルーティングを同じページに遷移させるには、Razorページの上部で `@page` を複数使うことで実現することができます。

```csharp
@page "/path1"
@page "/path/to/route1"
@page "/path/to/route2"

<h3>複数のルーティングを指定する</h3>
```

以上です。
