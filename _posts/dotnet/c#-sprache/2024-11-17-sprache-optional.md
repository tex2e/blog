---
layout:        post
title:         "[C#] 構文解析器Spracheで0回または1回出現する文字列にマッチさせる (Optional)"
date:          2024-11-17
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

構文解析器のSpracheで0回または1回出現するOptionalな文字列を読み取るメソッド一覧について説明します。


### Optional()

Parserがオプションであることを示します。
Parserは読み取りが成功するか失敗するかに関わらず、常に成功を返すようになります。
なお、マッチに失敗した場合は IOption 型が返ってくるため、.GetOrDefault() で結果を取り出します。

- `Parser<IOption<T>> Optional<T>(this Parser<T> parser)`

```csharp
Parser<string> identifier = Parse.Identifier(Parse.Letter, Parse.LetterOrDigit);

Parser<string> label =
    from labelName in identifier.Token()
    from colon in Parse.Char(':').Token()
    select labelName;

Parser<Tuple<string, string[]>> instruction =
    from instructionName in Parse.LetterOrDigit.Many().Text().Token()
    from operands in identifier.Token().XDelimitedBy(Parse.Char(','))
    select Tuple.Create(instructionName, operands.ToArray());

// Example of returning anonymous type from a sprache parser
var assemblyLine =
    from l in label.Optional()
    from i in instruction.Optional()
    select new {Label = l, Instruction = i};

Assert.Equal("test", assemblyLine.Parse("test: mov ax, bx").Label.Get());
Assert.False(assemblyLine.Parse("mov ax, bx").Label.IsDefined);
```


### XOptional()

Optionalの排他的 (eXclusive) 版です。

- `Parser<IOption<T>> XOptional<T>(this Parser<T> parser)`

```csharp
Parser<string> identifier = Parse.Identifier(Parse.Letter, Parse.LetterOrDigit);

Parser<string> label =
    from labelName in identifier.Token()
    from colon in Parse.Char(':').Token()
    select labelName;

// unexpected 'l'; expected :
Assert.Throws<ParseException>(() => label.XOptional().Parse("invalid label:"));
```


以上です。

### 参考資料

- [sprache/Sprache: A tiny, friendly, C# parser construction library](https://github.com/sprache/Sprache)
- [Sprache Part 10: Optional and XOptional - Justin Pealing](https://justinpealing.me.uk/post/2021-02-14-sprache10-optional/)
- Optional
    - [Sprache/src/Sprache/Parse.Optional.cs -- Optional](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.Optional.cs#L16)
- XOptional
    - [Sprache/src/Sprache/Parse.Optional.cs -- XOptional](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.Optional.cs#L38)
