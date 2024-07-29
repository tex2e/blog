---
layout:        post
title:         "[C#] 例外を再スローするときの注意点"
date:          2024-07-29
category:      C#
cover:         /assets/cover14.jpg
redirect_from:
comments:      true
published:     true
latex:         false
photoswipe:    false
# sitemap: false
# feed:    false
---

元の例外を再スローすると、元の例外にあったスタックトレースが途切れてしまいます。
以下のように、throw ex と実装するのは推奨されない書き方です。

```csharp
try
{
    RaiseException();
}
catch (InvalidOperationException ex)
{
    throw ex;  // スタックトレースが途切れる実装
}
```

上記のように実装してしまうと、RaiseException() 内部でエラーが発生した時に、その内部のスタックトレースが失われてしまいます。
そのため、デバッグするときに元の例外がどこで発生したのかがわからなくなり、原因の特定が困難になります。
この問題を回避するには、次のように throw の後に引数を指定しないように実装してください。

```csharp
try
{
    RaiseException();
}
catch (InvalidOperationException ex)
{
    throw;  // 正しい実装
}
```

以上です。

### 参考資料

- [例外のベスト プラクティス - .NET \| Microsoft Learn](https://learn.microsoft.com/ja-jp/dotnet/standard/exceptions/best-practices-for-exceptions)
