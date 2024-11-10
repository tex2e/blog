---
layout:        post
title:         "[C#] 構文解析器Spracheで繰り返し読み取る"
date:          2024-11-11
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

構文解析器のSpracheで特定のパターンを繰り返し読み取るためのメソッド一覧について説明します。


### Many()
パターンが0回以上出現する文字列を読み取ります。

- `Parser<IEnumerable<T>> Many<T>(this Parser<T> parser)`

```csharp
Parser<string> quotedString =
    from open in Parse.Char('"')
    from value in Parse.CharExcept('"').Many().Text()
    from close in Parse.Char('"')
    select value;

Assert.Equal("Hello, World!", quotedString.Parse("\"Hello, World!\""));
Assert.Equal("", quotedString.Parse("\"\""));
```


### XMany()
パターンが0回以上出現する文字列を読み取ります。
ただし、XMany はバックトラックが発生しないため、Many よりもエラーメッセージから問題点を見つけやすくなります。

- `Parser<IEnumerable<T>> XMany<T>(this Parser<T> parser)`

```csharp
// Single record e.g. "(monday)"
Parser<string> record =
    from lparem in Parse.Char('(')
    from name in Parse.Letter.Many().Text()
    from rparem in Parse.Char(')')
    select name;

string input = "(monday)(tuesday0(wednesday)(thursday)";

Assert.Equal(["monday"], record.Many().Parse(input));

// unexpected '('; expected end of input
Assert.Throws<ParseException>(() => record.XMany().End().Parse(input));

// unexpected '0'; expected )
Assert.Throws<ParseException>(() => record.XMany().Parse(input));
```


### AtLeastOnce()
パターンが1回以上出現する文字列を読み取ります。

- `Parser<IEnumerable<T>> AtLeastOnce<T>(this Parser<T> parser)`

```csharp
Parser<IEnumerable<string>> parser = Parse.String("Foo").Text().AtLeastOnce();

Assert.Equal(["Foo", "Foo"], parser.Parse("FooFooBar"));

// unexpected 'B'; expected Foo
Assert.Throws<ParseException>(() => parser.Parse("Bar"));
```


### XAtLeastOnce()
パターンが1回以上出現する文字列を読み取ります。
1個目のパターン以降は、すべて XMany() で読み取りを試みます。

- `Parser<IEnumerable<T>> XAtLeastOnce<T>(this Parser<T> parser)`

```csharp
Parser<IEnumerable<string>> parser = Parse.String("Foo").Text().XAtLeastOnce();

Assert.Equal(["Foo", "Foo"], parser.Parse("FooFooBar"));

// unexpected 'B'; expected Foo
Assert.Throws<ParseException>(() => parser.Parse("Bar"));
```


### Until()
引数のパターンにマッチするまで文字を読み取り続けます。

- `Parser<IEnumerable<T>> Until<T, U>(this Parser<T> parser, Parser<U> until)`

```csharp
Parser<string> parser =
    from first in Parse.String("/*")
    from comment in Parse.AnyChar.Until(Parse.String("*/")).Text()
    select comment;

Assert.Equal("this is a comment", parser.Parse("/*this is a comment*/"));

parser.Parse(
    @"/*
    This comment
    can span
    over multiple lines*/");
```


### Repeat()
引数で指定した回数繰り返し出現するパターンのみ読み取りします。

- `Parser<IEnumerable<T>> Repeat<T>(this Parser<T> parser, int count)`
- `Parser<IEnumerable<T>> Repeat<T>(this Parser<T> parser, int? minimumCount, int? maximumCount)`

```csharp
Parser<string> parserRepeat3Times = Parse.Char('a').Repeat(3).Text();
Assert.Equal("aaa", parserRepeat3Times.Parse("aaa"));
Assert.Throws<ParseException>(() => parserRepeat3Times.Parse("aab"));

Parser<string> parser = Parse.Digit.Repeat(3, 6).Text();
Assert.Equal("123", parser.Parse("123"));
Assert.Equal("123456", parser.Parse("123456"));
// 繰り返しの最大値以上は読み取らない
Assert.Equal("123456", parser.Parse("123456789"));
// Unexpected 'end of input'; expected 'digit' between 3 and 6 times, but found 2
Assert.Throws<ParseException>(() => parser.Parse("12"));
```


### Once()
1回のみ出現するパターンのみ読み取りします。
string型をIEnumerable\<string\>型に変換するときなどに利用します。

- `Parser<IEnumerable<T>> Once<T>(this Parser<T> parser)`

```csharp
Parser<string> identifier = Parse.Identifier(Parse.Letter, Parse.LetterOrDigit);

Parser<IEnumerable<string>> memberAccess =
    from first in identifier.Once()
    from subs in Parse.Char('.').Then(_ => identifier).Many()
    select first.Concat(subs);

Assert.Equal(["foo", "bar", "baz"], memberAccess.Parse("foo.bar.baz"));
```


以上です。

### 参考資料

- [sprache/Sprache: A tiny, friendly, C# parser construction library](https://github.com/sprache/Sprache)
- [Sprache Part 3: Repetition (Many, AtLeastOnce, Until, Repeat, Once) - Justin Pealing](https://justinpealing.me.uk/post/2020-03-23-sprache3-repetition/)
- Many()
    - [Sprache/src/Sprache/Parse.cs -- Many](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L256)
    - [Sprache/src/Sprache/Parse.cs -- XMany](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L296)
- AtLeastOnce()
    - [Sprache/src/Sprache/Parse.cs -- AtLeastOnce](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L309)
    - [Sprache/src/Sprache/Parse.cs -- XAtLeastOnce](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L323)
- Until()
    - [Sprache/src/Sprache/Parse.cs -- Until](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L602)
- Repeat()
    - [Sprache/src/Sprache/Parse.Sequence.cs -- Repeat(int)](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.Sequence.cs#L77)
    - [Sprache/src/Sprache/Parse.Sequence.cs -- Repeat(int, int)](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.Sequence.cs#L91)
- Once()
    - [Sprache/src/Sprache/Parse.cs -- Once](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L523)



