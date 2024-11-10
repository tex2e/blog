---
layout:        post
title:         "[C#] 構文解析器Spracheで可変長引数を解析する (DelimitedBy)"
date:          2024-11-14
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

構文解析器のSpracheでカンマ区切りなどで表される可変長引数を読み取るメソッド一覧について説明します。


### DelimitedBy()

第2引数のParserを区切り文字として、第1引数のParserで読み取ります。

- `Parser<IEnumerable<T>> DelimitedBy<T, U>(this Parser<T> parser, Parser<U> delimiter)`

```csharp
Parser<string> typeReference = Parse.Identifier(Parse.Letter, Parse.LetterOrDigit);

Parser<IEnumerable<string>> typeParameters =
    from open in Parse.Char('<')
    from elements in typeReference.DelimitedBy(Parse.Char(',').Token())
    from close in Parse.Char('>')
    select elements;

Assert.Equal(["string"], typeParameters.Parse("<string>"));
Assert.Equal(["string", "int"], typeParameters.Parse("<string, int>"));

// unexpected ','; expected >
Assert.Throws<ParseException>(() => typeParameters.Parse("<string,>"));

// unexpected '>'; expected letter
Assert.Throws<ParseException>(() => typeParameters.Parse("<>"));
```

上記は C# におけるジェネリックの表現を Sprache で解析して型の一覧をリストにする方法の一例です。

DelimitedBy を使うときの注意点として、末尾の区切り文字は読み取りを行いません。
そのため、末尾に区切り文字が入力される可能性があるときは、Optional() を使って末尾の区切り文字を許容した読み取りにする必要があります。

```csharp
Parser<IEnumerable<string>> array =
    from open in Parse.Char('[')
    from elements in Parse.Number.DelimitedBy(Parse.Char(',').Token()).Optional()
    from trailing in Parse.Char(',').Token().Optional()
    from close in Parse.Char(']')
    select elements.GetOrElse([]);

Assert.Equal(["1", "2", "3"], array.Parse("[1, 2, 3]"));
Assert.Equal(["1", "2"], array.Parse("[1, 2, ]"));
Assert.Equal([], array.Parse("[]"));
```


### XDelimitedBy()

基本的に DelimitedBy と同じですが、Parserが1文字以上マッチして全体にはマッチしないときに、ParseExceptionエラーを返すようになります。

- `Parser<IEnumerable<T>> XDelimitedBy<T, U>(this Parser<T> itemParser, Parser<U> delimiter)`

```csharp
Parser<IEnumerable<string>> numbers = Parse.Number.DelimitedBy(Parse.Char(',').Token());
Parser<IEnumerable<string>> numbersX = Parse.Number.XDelimitedBy(Parse.Char(',').Token());

Assert.Equal(["1", "2"], numbers.Parse("1, 2, "));
Assert.Throws<ParseException>(() => numbersX.Parse("1, 2, "));

Assert.Equal(["1", "2"], numbers.Parse("1, 2a, 3"));
Assert.Equal(["1", "2"], numbersX.Parse("1, 2a, 3"));

Assert.Equal(["1", "2"], numbers.Parse("1, 2 "));
Assert.Throws<ParseException>(() => numbersX.Parse("1, 2 "));  // 区切り文字の前後空白にマッチするためエラーする
```


以上です。

### 参考資料

- [sprache/Sprache: A tiny, friendly, C# parser construction library](https://github.com/sprache/Sprache)
- [Sprache Part 6: DelimitedBy - Justin Pealing](https://justinpealing.me.uk/post/2020-04-13-sprache6-delimitedby/)
- DelimitedBy
    - [Sprache/src/Sprache/Parse.Sequence.cs -- DelimitedBy](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.Sequence.cs#L34)
- XDelimitedBy
    - [Sprache/src/Sprache/Parse.Sequence.cs -- XDelimitedBy](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.Sequence.cs#L56)

