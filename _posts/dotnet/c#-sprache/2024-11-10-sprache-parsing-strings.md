---
layout:        post
title:         "[C#] 構文解析器Spracheで文字列を読み取る"
date:          2024-11-10
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

構文解析器のSpracheで文字列を読み取るためのメソッド一覧について説明します。


### String()

引数に指定した文字列と一致するときのみ読み取ります。結果は char のリストを返します。

- `Parser<IEnumerable<char>> String(string s)`

```csharp
Parser<IEnumerable<char>> keywordReturn = Parse.String("return");
Assert.Equal(['r', 'e', 't', 'u', 'r', 'n'], keywordReturn.Parse("return"));
```


### Text()

文字列にマッチしたとき、その結果を string型で返します。

- `Parser<string> Text(this Parser<IEnumerable<char>> characters)`

```csharp
Parser<string> keywordReturn = Parse.String("return").Text();
Assert.Equal("return", keywordReturn.Parse("return"));

Parser<string> parser = Parse.CharExcept(',').Many().Text();
Assert.Equal("foo", parser.Parse("foo,bar"));
```


### IgnoreCase()

引数の文字列を大文字小文字を無視して読み取ります。

- `Parser<char> IgnoreCase(char c)`
- `Parser<IEnumerable<char>> IgnoreCase(string s)`

```csharp
Parser<char> parseChar = Parse.IgnoreCase('a');
Assert.Equal('a', parseChar.Parse("a"));
Assert.Equal('A', parseChar.Parse("A"));

Parser<string> sprach = Parse.IgnoreCase("sprache").Text();
Assert.Equal("SprachE", sprach.Parse("SprachE"));
```


### Number

数値を読み取ります。ただし、小数点にはマッチしません。

- `Parser<string> Number = Numeric.AtLeastOnce().Text()`

```csharp
Assert.Equal("123", Parse.Number.Parse("123"));

// 小数点は数値に含まれないため注意
Assert.Equal("1", Parse.Number.Parse("1.23"));
```


### Decimal

数値を読み取ります。小数点にもマッチするため、小数点以下の値も読み取ることができます。

- `Parser<string> Decimal`

```csharp
System.Globalization.CultureInfo.CurrentCulture = new System.Globalization.CultureInfo("fr-FR");
Assert.Equal("123,45", Parse.Decimal.Parse("123,45"));
System.Globalization.CultureInfo.CurrentCulture = new System.Globalization.CultureInfo("fr-FR");
Assert.Equal("123.45", Parse.DecimalInvariant.Parse("123.45"));
```

なお、Parse.Decimalを使うと、実行環境のカルチャに合わせて小数点の読み取り方法が変化します。
フランスでは小数点にカンマ「,」を使用するため、Parse.Decimal で読み取ると現在の国に合わせて小数点の読み取りが行われます。

一方で、Parse.DecimalInvariant を使うと、常に小数点は「.」で読み取ります。


### LineEnd

改行のLF「\\n」またはCRLF「\\r\\n」を読み取ります。

- `Parser<string> LineEnd`

```csharp
Assert.Equal("\r\n", Parse.LineEnd.Parse("\r\n"));
Assert.Equal("\n", Parse.LineEnd.Parse("\n"));

// Unexpected end of input reached; expected 
Assert.Throws<ParseException>(() => Parse.LineEnd.Parse("\r"));
```


### Token()

前後の空白を取り除いた上で、解析器による読み取りを行います。

- `Parser<T> Token<T>(this Parser<T> parser)`

```csharp
Parser<int> expression =
    from left in Parse.Number.Token()
    from plus in Parse.Char('+').Token()
    from right in Parse.Number.Token()
    select int.Parse(left) + int.Parse(right);

Assert.Equal(4, expression.Parse("2 + 2"));
Assert.Equal(4, expression.Parse(" 2 + 2"));
Assert.Equal(4, expression.Parse("\n2\n  +   \n 2 \n "));
```


### Contained()

対象の文字列の前後に囲み文字がある解析器を作るためのヘルパーメソッドです。囲み文字の中の文字列の読み取りを行います。

- `Parser<T> Contained<T, U, V>(this Parser<T> parser, Parser<U> open, Parser<V> close)`

```csharp
Parser<string> parser = Parse.Letter.Many().Text().Contained(Parse.Char('('), Parse.Char(')'));

Assert.Equal("foo", parser.Parse("(foo)"));
Assert.Equal("", parser.Parse("()"));

// Unexpected end of input reached; expected )
Assert.Throws<ParseException>(() => parser.Parse("(foo"));
```


### Identifier()

識別子の読み取りを行うためのヘルパーメソッドです。第1引数の解析器で読み取った後に、残りは第2引数の解析器で読み取ります。

- `Parser<string> Identifier(Parser<char> firstLetterParser, Parser<char> tailLetterParser)`

```csharp
Parser<string> identifier = Parse.Identifier(Parse.Letter, Parse.LetterOrDigit);

Assert.Equal("d1", identifier.Parse("d1"));

// unexpected '1'; expected letter
Assert.Throws<ParseException>(() => identifier.Parse("1d"));
```


### LineTerminator

行の終端を読み取ります。空文字を読み取るときもマッチするため、解析エラーは発生しません。

- `Parser<string> LineTerminator`

```csharp
Parser<string> parser = Parse.LineTerminator;

Assert.Equal("", parser.Parse(""));
Assert.Equal("\n", parser.Parse("\n foo"));
Assert.Equal("\r\n", parser.Parse("\r\n foo"));
```



以上です。

### 参考資料

- [sprache/Sprache: A tiny, friendly, C# parser construction library](https://github.com/sprache/Sprache)
- [Sprache Part 2: Parsing Strings - Justin Pealing](https://justinpealing.me.uk/post/2020-03-16-sprache2-strings/)
- [Sprache Part 8: Token, Contained, Identifier, LineTerminator - Justin Pealing](https://justinpealing.me.uk/post/2020-04-29-sprache8-token-etc/)
- String()
    - [Sprache/src/Sprache/Parse.cs -- String](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L196)
- Text()
    - [Sprache/src/Sprache/Parse.cs -- Text](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L420)
- IgnoreCase()
    - [Sprache/src/Sprache/Parse.cs -- IgnoreCase(char)](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L129)
    - [Sprache/src/Sprache/Parse.cs -- IgnoreCase(string)](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L139)
- Number
    - [Sprache/src/Sprache/Parse.cs -- Number](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L763)
- Decimal
    - [Sprache/src/Sprache/Parse.cs -- Decimal](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L782)
    - [Sprache/src/Sprache/Parse.cs -- DecimalInvariant](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L787)
- LineEnd
    - [Sprache/src/Sprache/Parse.Primitives.cs -- LineEnd](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.Primitives.cs#L8)
- Token()
    - [Sprache/src/Sprache/Parse.cs -- Token](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L371)
- Contained()
    - [Sprache/src/Sprache/Parse.Sequence.cs -- Contained](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.Sequence.cs#L146)
- Identifier()
    - [Sprache/src/Sprache/Parse.Primitives.cs -- Identifier](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.Primitives.cs#L26)
- LineTerminator
    - [Sprache/src/Sprache/Parse.Primitives.cs -- LineTerminator](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.Primitives.cs#L17C23-L17C52)
