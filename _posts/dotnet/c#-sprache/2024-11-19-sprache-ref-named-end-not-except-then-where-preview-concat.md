---
layout:        post
title:         "[C#] 構文解析器Spracheの便利メソッド一覧 (Ref, Named, End, Not, Except, Then, Where, Preview, Concat)"
date:          2024-11-19
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

構文解析器Spracheでその他の便利メソッド一覧について説明します。


### Ref()

Ref は循環依存でコンパイルできない問題を解決するために使用します。
これにより、コンパイル時ではなく、呼び出されたときに Parser を解決する遅延評価を行うようになります。

- `Parser<T> Ref<T>(Func<Parser<T>> reference)`

```csharp
Assert.Equal(26, MyParserRef.AdditiveExpression.End().Parse("1+(2+3)*4+5"));


class MyParserRef
{
    public static readonly Parser<float> Integer =
        Parse.Number.Token().Select(float.Parse);

    public static readonly Parser<float> PrimaryExpression =
        Integer.Or(Parse.Ref(() => AdditiveExpression).Contained(Parse.Char('('), Parse.Char(')')));

    public static readonly Parser<float> MultiplicativeExpression =
        Parse.ChainOperator(Parse.Char('*'), PrimaryExpression, (c, left, right) => left * right);

    public static readonly Parser<float> AdditiveExpression =
        Parse.ChainOperator(Parse.Char('+'), MultiplicativeExpression, (c, left, right) => left + right);
}
```


### Named()

読み取りエラー出力時に表示される、次に期待される構文パターン名称を指定することができます。

- `Parser<T> Named<T>(this Parser<T> parser, string name)`

```csharp
Parser<string> quotedText =
    (from open in Parse.Char('"')
        from content in Parse.CharExcept('"').Many().Text()
        from close in Parse.Char('"')
        select content).Named("quoted text");

// This throws:
//   unexpected 'f'; expected quoted text
// instead of:
//   unexpected 'f'; expected "
Assert.Throws<ParseException>(() => quotedText.Parse("foo"));
```


### End()

入力の終端まで読み取り続けます。一般的には Many() と組み合わせて、最後まで読み取るときに使います。

- `Parser<T> End<T>(this Parser<T> parser)`

```csharp
Assert.Equal("12", Parse.Number.End().Parse("12"));

// unexpected '_'; expected end of input
Assert.Throws<ParseException>(() => Parse.Number.End().Parse("12_"));
```


### Not()

入力の文字列に一致しないときのみ読み取りに成功します。
ただし、読み取った結果は消費しないため、正規表現の否定先読みのような動きになります。

- `Parser<object> Not<T>(this Parser<T> parser)`

```csharp
Parser<string> Keyword(string text) =>
    Parse.IgnoreCase(text).Then(n => Parse.Not(Parse.LetterOrDigit.Or(Parse.Char('_')))).Return(text);

Parser<string> returnKeyword = Keyword("return");

Assert.Equal("return", returnKeyword.Parse("return"));
Assert.Throws<ParseException>(() => returnKeyword.Parse("return_"));
Assert.Throws<ParseException>(() => returnKeyword.Parse("returna"));
```


### Except()

Exceptで指定したParserにマッチしないときのみ、読み取りを行います。

- `Parser<T> Except<T, U>(this Parser<T> parser, Parser<U> except)`

```csharp
const char Quote = '\'';
const char OpenCurly = '{';
const char CloseCurly = '}';
const char Comma = ',';
const char EqualSign = '=';

Parser<char> validChars =
    Parse.AnyChar.Except(
        Parse.Chars(Quote, OpenCurly, CloseCurly, EqualSign, Comma).Or(Parse.WhiteSpace));

Assert.Equal('t', validChars.Parse("t"));
Assert.Throws<ParseException>(() => validChars.Parse(" "));
```


### Then()

Thenの元となるParserの読み取りが成功したとき、Thenの引数のParserで読み取りを試みます。
Thenの引数のParserが読み取り成功すると、その結果を返します。

- `Parser<U> Then<T, U>(this Parser<T> first, Func<T, Parser<U>> second)`

```csharp
Parser<string> identifier = Parse.Identifier(Parse.Letter, Parse.LetterOrDigit);

Parser<string[]> memberAccess =
    from first in identifier.Once()
    from subs in Parse.Char('.').Then(_ => identifier).Many()
    select first.Concat(subs).ToArray();

Assert.Equal(["foo", "bar", "baz"], memberAccess.Parse("foo.bar.baz"));
```


### Where()

条件に一致したときのみ読み取りを成功とします。

- `Parser<T> Where<T>(this Parser<T> parser, Func<T, bool> predicate)`

```csharp
Parser<int> parser = Parse.Number.Select(int.Parse).Where(n => n >= 100 && n < 200);

Assert.Equal(151, parser.Parse("151"));

// Unexpected 201.;
Assert.Throws<ParseException>(() => parser.Parse("201"));
```

where は LINQ の構文を使っても指定することができます。

```csharp
string[] keywords = ["return", "var", "function"];

Parser<string> identifier =
    from id in Parse.Identifier(Parse.Letter, Parse.LetterOrDigit.Or(Parse.Char('_')))
    where !keywords.Contains(id)
    select id;

// Unexpected return.;
Assert.Throws<ParseException>(() => identifier.Parse("return"));
```


### Concat()

2つのParserを1つにまとめることができます。

- `Parser<IEnumerable<T>> Concat<T>(this Parser<IEnumerable<T>> first, Parser<IEnumerable<T>> second)`

```csharp
Parser<string> identifierRule =
    (from first in Parse.Letter.Once()
    from rest in Parse.LetterOrDigit.XOr(Parse.Char('_')).Many()
    select new string(first.Concat(rest).ToArray())).Named("identifier");

Assert.Equal("my_variable1", identifierRule.Parse("my_variable1"));
```


### Preview()

入力の文字列に一致するときのみ読み取りに成功します。
ただし、読み取った結果は消費しないため、正規表現の肯定先読みのような動きになります。

- `Parser<IOption<T>> Preview<T>(this Parser<T> parser)`

```csharp
var parser =
    from name in Parse.Identifier(Parse.Letter, Parse.LetterOrDigit).Text()
    from hash in Parse.Char('#').Preview()
    from hashtag in Parse.AnyChar.Until(Parse.LineTerminator).Text()
    select new { NAME = name, HASHTAG = hashtag, HAS_HASH = !hash.IsEmpty };

var result = parser.Parse("foo#bar123");
Assert.Equal("foo", result.NAME);
Assert.Equal("#bar123", result.HASHTAG);
Assert.True(result.HAS_HASH);

var result2 = parser.Parse("foo_bar123");
Assert.Equal("foo", result2.NAME);
Assert.Equal("_bar123", result2.HASHTAG);
Assert.False(result2.HAS_HASH);
```


### Span()

Parserが読み取った結果を ITextSpan 型にして返します。
ITextSpan 型は読み取った文字列の位置情報などが含まれています。

- `Parser<ITextSpan<T>> Span<T>(this Parser<T> parser)`

```csharp
Parser<string> sample =
    from a in Parse.Char('a').Many().Text().Token()
    from b in Parse.Char('b').Many().Text().Token().Span()
    where b.Start.Pos <= 10
    select a + b.Value;

Assert.Equal("aaabbb", sample.Parse(" aaa bbb "));
Assert.Throws<ParseException>(() => sample.Parse(" aaaaaaa      bbbbbb "));
```



以上です。

### 参考資料

- [sprache/Sprache: A tiny, friendly, C# parser construction library](https://github.com/sprache/Sprache)
- [Sprache Part 12: Ref, Named, End, Not, Except, Then, Where, Preview, Concat - Justin Pealing](https://justinpealing.me.uk/post/2021-04-14-sprache12-ref-etc/)
- Ref()
    - [Sprache/src/Sprache/Parse.cs -- Ref](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L387)
- Named()
    - [Sprache/src/Sprache/Parse.cs -- Named](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L459)
- End()
    - [Sprache/src/Sprache/Parse.cs -- End](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L336)
- Not()
    - [Sprache/src/Sprache/Parse.cs -- Not](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L216)
- Except()
    - [Sprache/src/Sprache/Parse.cs -- Except](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L578C23-L578C86)
- Then()
    - [Sprache/src/Sprache/Parse.cs -- Then](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L241)
- Where()
    - [Sprache/src/Sprache/Parse.cs -- Where](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L614)
- Concat()
    - [Sprache/src/Sprache/Parse.cs -- Concat](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L537)
- Preview()
    - [Sprache/src/Sprache/Parse.Optional.cs -- Preview](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.Optional.cs#L65)
    - [Sprache/src/Sprache/Option.cs -- IOption\#IsEmpty](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Option.cs#L14)
- Span()
    - [Sprache/src/Sprache/Parse.Commented.cs -- Span](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.Commented.cs#L30)

