---
layout:        post
title:         "[C#] 構文解析器Spracheで解析結果を別の型に変換する"
date:          2024-11-13
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

構文解析器のSpracheで読み取った結果を別の型に変えるメソッド一覧について説明します。


### Select()

Parserで読み取った結果を、関数やラムダ式を使って別の値や型に変換します。

- `Parser<U> Select<T, U>(this Parser<T> parser, Func<T, U> convert)`

```csharp
Parser<int> number = Parse.Number.Select(int.Parse);
Assert.Equal(12, number.Parse("12"));

Parser<int> numberLambda = Parse.Number.Select(x => int.Parse(x));
Assert.Equal(123, numberLambda.Parse("123"));

var identifier =
    from first in Parse.Letter.Once()
    from rest in Parse.LetterOrDigit.XOr(Parse.Char('-')).XOr(Parse.Char('_')).Many()
    select new string(first.Concat(rest).ToArray());

var tag =
    from lt in Parse.Char('<')
    from t in identifier
    from gt in Parse.Char('>').Token()
    select t;

Assert.Equal("test", tag.Parse("<test>"));
```


### Return()

Parserで読み取りが成功したら、Retrun()の引数で指定した値を返します。

- `Parser<T> Return<T>(T value)`
- `Parser<U> Return<T, U>(this Parser<T> parser, U value)`

```csharp
Parser<OperatorType> parser = Parse.String("*").Then(_ => Parse.Return(OperatorType.Mul));
Assert.Equal(OperatorType.Mul, parser.Parse("*"));

Parser<OperatorType> add = Parse.String("+").Return(OperatorType.Add);
Assert.Equal(OperatorType.Add, add.Parse("+"));
```

上記のReturnする値は enum で以下のようなものを想定しています。実際は string 型でも int 型でもなんでも良いです。

```csharp
public enum OperatorType
{
    Add,
    Sub,
    Mul,
    Div
}
```


### Regex()

正規表現でマッチするParserで読み取ります。成功時はマッチした文字列全体を返します。

- `Parser<string> Regex(string pattern, string description = null)`
- `Parser<string> Regex(Regex regex, string description = null)`

```csharp
Parser<string> digits = Parse.Regex(@"\d(\d*)");

Assert.Equal("123", digits.Parse("123d"));
Assert.Throws<ParseException>(() => digits.Parse("d123"));
```


### RegexMatch()

正規表現でマッチするParserで読み取ります。成功時は正規表現の Match オブジェクトを返します。

- `Parser<Match> RegexMatch(string pattern, string description = null)`
- `Parser<Match> RegexMatch(Regex regex, string description = null)`

```csharp
Parser<Match> digits = Parse.RegexMatch(@"(\d+)-(\d+)");

Assert.Equal("123", digits.Parse("123-4567").Groups[1].Value);
Assert.Equal("4567", digits.Parse("123-4567").Groups[2].Value);
```


以上です。

### 参考資料

- [sprache/Sprache: A tiny, friendly, C# parser construction library](https://github.com/sprache/Sprache)
- [Sprache Part 5: Select, Return, and Regex - Justin Pealing](https://justinpealing.me.uk/post/2020-04-06-sprache5-select-and-return/)
- Select()
    - [Sprache/src/Sprache/Parse.cs -- Select](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L357)
- Return()
    - [Sprache/src/Sprache/Parse.cs -- Return\<T\>(T)](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L551)
    - [Sprache/src/Sprache/Parse.cs -- Return\<T, U\>(this Parser\<T\>, U)](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L564)
- Regex()
    - [Sprache/src/Sprache/Parse.Regex.cs -- Regex(string)](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.Regex.cs#L14)
    - [Sprache/src/Sprache/Parse.Regex.cs -- Regex(Regex)](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.Regex.cs#L27)
- RegexMatch()
    - [Sprache/src/Sprache/Parse.Regex.cs -- RegexMatch(string)](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.Regex.cs#L41)
    - [Sprache/src/Sprache/Parse.Regex.cs -- RegexMatch(Regex)](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.Regex.cs#L55)

