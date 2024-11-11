---
layout:        post
title:         "[C#] 構文解析器Spracheでコメントを読み取る (CommentParser)"
date:          2024-11-18
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

構文解析器のSpracheでコメントを読み取るメソッド一覧について説明します。


### Comment()

CommentParser の引数でコメントの記載方法を指定します。
引数が3つのときは範囲コメントのみ読み取ることができます。
引数が4つのときは単行コメントと範囲コメントの両方を読み取ることができます。

- `CommentParser(string multiOpen, string multiClose, string newLine)`
- `CommentParser(string single, string multiOpen, string multiClose, string newLine)`

CommentParser クラスをインスタンス化すると、以下のメソッドが使用できるようになります。

- `Parser<string> AnyComment`
- `Parser<string> MultiLineComment`
- `Parser<string> SingleLineComment`

```csharp
var comment = new CommentParser("<!--", "-->", "\r\n");

Assert.Equal(" Commented text ", comment.AnyComment.Parse("<!-- Commented text -->"));

// 単行コメントが未設定のときに SingleLineComment を呼び出すとエラーになる
Assert.Throws<ParseException>(() => comment.SingleLineComment);
```

引数省略時は new CommentParser("//", "/*", "*/", "\n") と同じになります。

```csharp
var comment = new CommentParser();

Assert.Equal("single-line comment", comment.SingleLineComment.Parse("//single-line comment"));
Assert.Equal("multi-line comment", comment.MultiLineComment.Parse("/*multi-line comment*/"));
```


以上です。

### 参考資料

- [sprache/Sprache: A tiny, friendly, C# parser construction library](https://github.com/sprache/Sprache)
- [Sprache Part 11: Parsing Comments - Justin Pealing](https://justinpealing.me.uk/post/2021-03-14-sprache11-commentparser/)
- CommentParser
    - [Sprache/src/Sprache/CommentParser.cs -- CommentParser](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/CommentParser.cs#L6)
    - [Sprache/src/Sprache/CommentParser.cs -- CommentParser#AnyComment](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/CommentParser.cs#L109)
    - [Sprache/src/Sprache/CommentParser.cs -- CommentParser#SingleLineComment](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/CommentParser.cs#L72)
    - [Sprache/src/Sprache/CommentParser.cs -- CommentParser#MultiLineComment](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/CommentParser.cs#L89)
