---
layout:        post
title:         "[C#] 構文解析器Spracheで左結合・右結合を解析する (ChainOperator)"
date:          2024-11-15
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

構文解析器のSpracheで左結合演算子や右結合演算子を読み取るメソッド一覧について説明します。



### ChainOperator()

左結合で演算子を読み取ります。

- `Parser<T> ChainOperator<T, TOp>(Parser<TOp> op, Parser<T> operand, Func<TOp, T, T, T> apply)`

```csharp
{
    Parser<char> add = Parse.Char('+').Token();
    Parser<int> number = Parse.Number.Token().Select(int.Parse);

    Parser<int> expr = Parse.ChainOperator(add, number, (op, left, right) => left + right);

    Assert.Equal(3, expr.Parse("1 + 2"));
    Assert.Equal(9, expr.Parse("1 + 2 + 3 + 3"));
    Assert.Equal(1, expr.Parse("1"));
    // Unexpected end of input reached; expected numeric character
    Assert.Throws<ParseException>(() => expr.Parse(""));
}

{
    Parser<char> add = Parse.Char('+').Token();
    Parser<char> subtract = Parse.Char('-').Token();
    Parser<string> number = Parse.Number.Token();

    Parser<string> expr = Parse.ChainOperator(add.Or(subtract), number, 
        (op, left, right) => $"({left} {op} {right})");

    Assert.Equal("(1 + 2)", expr.Parse("1 + 2"));
    Assert.Equal("(((1 + 2) - 3) + 3)", expr.Parse("1 + 2 - 3 + 3"));
    Assert.Equal("1", expr.Parse("1"));
}
```


### XChainOperator()

左結合で演算子を読み取ります。ただし、演算子のParserがマッチしたにも関わらず、後続のParserでマッチしなかった場合には、ParseExceptionを返します。

- `Parser<T> XChainOperator<T, TOp>(Parser<TOp> op, Parser<T> operand, Func<TOp, T, T, T> apply)`

```csharp
Parser<char> addOp = Parse.Char('+').Token();
Parser<int> number = Parse.Number.Token().Select(int.Parse);
Parser<int> addX = Parse.XChainOperator(addOp, number, (op, left, right) => left + right);

// unexpected 'a'; expected numeric character
Assert.Throws<ParseException>(() => addX.Parse("1 + 3 + aaa"));

Assert.Equal(8, addX.Parse("1 + 3 + 4a + 5"));
```


### ChainRightOperator()

右結合で演算子を読み取ります。

- `Parser<T> ChainRightOperator<T, TOp>(Parser<TOp> op, Parser<T> operand, Func<TOp, T, T, T> apply)`

```csharp
Parser<char> exp = Parse.Char('^').Token();
Parser<string> number = Parse.Number.Token();

Parser<string> expr = Parse.ChainRightOperator(exp, number, (op, left, right) => $"({left} {op} {right})");

Assert.Equal("(1 ^ 2)", expr.Parse("1 ^ 2"));
Assert.Equal("(1 ^ (2 ^ (3 ^ 3)))", expr.Parse("1 ^ 2 ^ 3 ^ 3"));
```


### XChainRightOperator()

右結合で演算子を読み取ります。ただし、演算子のParserがマッチしたにも関わらず、後続のParserでマッチしなかった場合には、ParseExceptionを返します。

- `Parser<T> XChainRightOperator<T, TOp>(Parser<TOp> op, Parser<T> operand, Func<TOp, T, T, T> apply)`

```csharp
Parser<char> exp = Parse.Char('^').Token();
Parser<string> number = Parse.Number.Token();

Parser<string> exprX = Parse.ChainRightOperator(exp, number, (op, left, right) => $"({left} {op} {right})");

Assert.Throws<ParseException>(() => exprX.Parse("a ^ 2 ^ 3"));
```


### 参考資料

- [sprache/Sprache: A tiny, friendly, C# parser construction library](https://github.com/sprache/Sprache)
- [Sprache Part 7: ChainOperator and ChainRightOperator - Justin Pealing](https://justinpealing.me.uk/post/2020-04-20-sprache7-operators/)
- ChainOperator
    - [Sprache/src/Sprache/Parse.cs -- ChainOperator](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L656)
    - [Sprache/src/Sprache/Parse.cs -- XChainOperator](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L676)
- ChainRightOperator
    - [Sprache/src/Sprache/Parse.cs -- ChainRightOperator](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L712)
    - [Sprache/src/Sprache/Parse.cs -- XChainRightOperator](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.cs#L732)



