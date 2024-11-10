---
layout:        post
title:         "[C#] 構文解析器Spracheで1文字を読み取る"
date:          2024-11-09
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

構文解析器のSpracheで1文字を読み取るためのメソッド一覧について説明します。


### Char()

任意の1文字を読み取ります。

- `Parser<char> Char(char c)`
- `Parser<char> Char(Predicate<char> predicate, string description)`

```csharp
Parser<char> multiply = Parse.Char('*');
Assert.Equal('*', multiply.Parse("*"));

Parser<char> punctuation = Parse.Char(char.IsPunctuation, "punctuation");
Assert.Equal(',', punctuation.Parse(","));
```

### Chars()

任意の1文字を読み取ります。読み取る対象の複数の文字一覧を指定することができます。

- `Parser<char> Chars(params char[] c)`
- `Parser<char> Chars(string c)`

```csharp
Parser<char> op = Parse.Chars('+', '-', '*', '/');
Assert.Equal('-', op.Parse("-"));
Assert.Equal('*', op.Parse("*"));

Parser<char> parens = Parse.Chars("()");
Assert.Equal(')', parens.Parse(")"));
```

### CharExcept()

任意の1文字を読み取ります。ただし、引数に指定した文字**以外**のみを読み取ります。

- `Parser<char> CharExcept(char c)`
- `Parser<char> CharExcept(IEnumerable<char> c)`
- `Parser<char> CharExcept(string c)`
- `Parser<char> CharExcept(Predicate<char> predicate, string description)`

```csharp
Parser<char> parser1 = Parse.CharExcept('"');
Assert.Equal('a', parser1.Parse("a"));
Assert.Throws<ParseException>(() => parser1.Parse("\""));

Parser<char> parser2 = Parse.CharExcept(['1', '2', '3']);
Assert.Equal('4', parser2.Parse("4"));
Assert.Throws<ParseException>(() => parser2.Parse("2"));

Parser<char> parser3 = Parse.CharExcept("123");
Assert.Equal('4', parser3.Parse("4"));
Assert.Throws<ParseException>(() => parser3.Parse("2"));

Parser<char> parser4 = Parse.CharExcept(char.IsPunctuation, "punctuation");
Assert.Equal('a', parser4.Parse("a"));
Assert.Throws<ParseException>(() => parser4.Parse("."));
```

### IgnoreCase()

引数の文字を大文字小文字を無視して読み取ります。

- `Parser<char> IgnoreCase(char c)`
- `Parser<IEnumerable<char>> IgnoreCase(string s)`

```csharp
Parser<char> parser = Parse.IgnoreCase('a');
Assert.Equal('A', parser.Parse("A"));

Parser<IEnumerable<char>> parserString = Parse.IgnoreCase("test");
Assert.Equal(['T','e','s','T'], parserString.Parse("TesT"));
```


### WhiteSpace

char.IsWhiteSpace() にマッチする空白や改行を読み取ります。

- `Parser<char> WhiteSpace = Char(char.IsWhiteSpace, "whitespace")`

```csharp
Assert.Equal(' ', Parse.WhiteSpace.Parse(" "));
Assert.Equal('\t', Parse.WhiteSpace.Parse("\t"));
Assert.Throws<ParseException>(() => Parse.WhiteSpace.Parse(""));
```


### Digit

char.IsDigit() にマッチする数字を読み取ります。

- `Parser<char> Digit = Char(char.IsDigit, "digit")`

```csharp
Assert.Equal('7', Parse.Digit.Parse("7"));
```



### Numeric

char.IsNumber() にマッチする数値を読み取ります。char.IsDigit よりも多くの数字とマッチします。
例えば、べき乗の「²」と「³」や、分数の「¼」と「½」などにもマッチします。

- `Parser<char> Numeric = Char(char.IsNumber, "numeric character")`

```csharp
Assert.Equal('1', Parse.Numeric.Parse("1"));
Assert.Equal('¼', Parse.Numeric.Parse("¼"));
```




### Letter

char.IsLetter() にマッチするアルファベットなどの文字を読み取ります。

- `Parser<char> Letter = Char(char.IsLetter, "letter")`

```csharp
Assert.Equal('a', Parse.Letter.Parse("a"));
Assert.Throws<ParseException>(() => Parse.Lower.Parse("1"));
Assert.Throws<ParseException>(() => Parse.Lower.Parse("あ"));
```



### LetterOrDigit

char.IsLetter() にマッチする文字、または char.IsDigit() にマッチする数字を読み取ります。

- `LetterOrDigit = Char(char.IsLetterOrDigit, "letter or digit")`

```csharp
Assert.Equal('a', Parse.LetterOrDigit.Parse("a"));
Assert.Equal('4', Parse.LetterOrDigit.Parse("4"));
```



### Lower

アルファベットの小文字を読み取ります。

- `Parser<char> Lower = Char(char.IsLower, "lowercase letter")`

```csharp
Assert.Equal('a', Parse.Lower.Parse("a"));
// unexpected '4'; expected lowercase letter
Assert.Throws<ParseException>(() => Parse.Lower.Parse("4"));
```



### Upper

アルファベットの大文字を読み取ります。

- `Parser<char> Upper = Char(char.IsUpper, "uppercase letter")`

```csharp
Assert.Equal('A', Parse.Upper.Parse("A"));
Assert.Throws<ParseException>(() => Parse.Upper.Parse("a"));
```



### AnyChar

全ての文字とマッチし、その1文字を読み取ります。

- `Parser<char> AnyChar = Char(c => true, "any character")`

```csharp
Assert.Equal('a', Parse.AnyChar.Parse("abcd"));
```




以上です。

### 参考資料

- [sprache/Sprache: A tiny, friendly, C# parser construction library](https://github.com/sprache/Sprache)
- [Sprache Part 1: Parsing Characters - Justin Pealing](https://justinpealing.me.uk/post/2020-03-11-sprache1-chars/)
- Char()
    - [Sprache/src/Sprache/Parse.cs -- Char(char)](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L66C40-L66C41)
    - [Sprache/src/Sprache/Parse.cs -- Char(Predicate\<char\>, string)](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L27)
- Chars()
    - [Sprache/src/Sprache/Parse.cs -- Chars(params char\[\])](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L77)
    - [Sprache/src/Sprache/Parse.cs -- Chars(string)](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L87)
- CharExcept()
    - [Sprache/src/Sprache/Parse.cs -- CharExcept(char)](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L98)
    - [Sprache/src/Sprache/Parse.cs -- CharExcept(IEnumerable\<char\>)](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L108)
    - [Sprache/src/Sprache/Parse.cs -- CharExcept(string)](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L119)
    - [Sprache/src/Sprache/Parse.cs -- CharExcept(Predicate\<char\>, string)](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L56)
- IgnoreCase()
    - [Sprache/src/Sprache/Parse.cs -- IgnoreCase(char)](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L129)
    - [Sprache/src/Sprache/Parse.cs -- IgnoreCase(string)](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L139)
- WhiteSpace
    - [Sprache/src/Sprache/Parse.cs -- WhiteSpace](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L159)
- Digit
    - [Sprache/src/Sprache/Parse.cs -- Digit](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L164)
- Numeric
    - [Sprache/src/Sprache/Parse.cs -- Numeric](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L189)
- Letter
    - [Sprache/src/Sprache/Parse.cs -- Letter](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L169)
- LetterOrDigit
    - [Sprache/src/Sprache/Parse.cs -- LetterOrDigit](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L174)
- Lower
    - [Sprache/src/Sprache/Parse.cs -- Lower](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L179)
- Upper
    - [Sprache/src/Sprache/Parse.cs -- Upper](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L184)
- AnyChar
    - [Sprache/src/Sprache/Parse.cs -- AnyChar](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L154)
