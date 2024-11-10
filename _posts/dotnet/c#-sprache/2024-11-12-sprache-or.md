---
layout:        post
title:         "[C#] 構文解析器Spracheで複数の選択肢を読み取る (Or)"
date:          2024-11-12
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

構文解析器のSpracheで複数の選択肢 (Or) を読み取るためのメソッド一覧について説明します。


### Or()

第1引数のParserでマッチしたときはその結果読み取った結果を返します。それ以外は、第2引数のParserで読み取りを試みます。

- `Parser<T> Or<T>(this Parser<T> first, Parser<T> second)`

```csharp
Parser<string> keyword = Parse.String("return")
    .Or(Parse.String("function"))
    .Or(Parse.String("switch"))
    .Or(Parse.String("if"))
    .Text();

Assert.Equal("return", keyword.Parse("return"));
Assert.Equal("if", keyword.Parse("if"));
```


### XOr()

XOrは最初のParserが1文字以上一致したときに、それ以降のParserで読み取りを試みません。

- `Parser<T> XOr<T>(this Parser<T> first, Parser<T> second)`

```csharp
var parser = Parse.String("foo")
    .XOr(Parse.Identifier(Parse.Letter, Parse.LetterOrDigit));

Assert.Equal("bar", parser.Parse("bar"));
//  unexpected 'a'; expected o
Assert.Throws<ParseException>(() => parser.Parse("far"));
```


以上です。

### 参考資料

- [sprache/Sprache: A tiny, friendly, C# parser construction library](https://github.com/sprache/Sprache)
- [Sprache Part 4: Or and XOr - Justin Pealing](https://justinpealing.me.uk/post/2020-03-30-sprache4-or/)
- Or()
    - [Sprache/src/Sprache/Parse.cs -- Or](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L432)
- XOr()
    - [Sprache/src/Sprache/Parse.cs -- XOr](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L477)



