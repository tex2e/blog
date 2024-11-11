---
layout:        post
title:         "[C#] 構文解析器Spracheで解析した字句の出現位置を保存する (Positioned)"
date:          2024-11-16
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

構文解析器Spracheで解析した字句の出現位置を保存するには、IPositionAware インターフェースを実装した結果を格納するクラスを用意し、解析時に Parser#Positioned() メソッドを呼び出す必要があります。

### Positioned()

読み取った結果に対して位置情報をセットします。

- `Parser<T> Positioned<T>(this Parser<T> parser) where T : IPositionAware<T>`

```csharp
Node root = MyParserPos.Expr.Parse("12 + \n345");

Assert.Equal(0, ((BinaryExpression)root).StartPos?.Pos);
Assert.Equal(1, ((BinaryExpression)root).StartPos?.Line);
Assert.Equal(1, ((BinaryExpression)root).StartPos?.Column);
Assert.Equal(9, ((BinaryExpression)root).Length);

Assert.Equal(0, ((BinaryExpression)root).Left.StartPos?.Pos);
Assert.Equal(1, ((BinaryExpression)root).Left.StartPos?.Line);
Assert.Equal(1, ((BinaryExpression)root).Left.StartPos?.Column);
Assert.Equal(3, ((BinaryExpression)root).Left.Length);

Assert.Equal(6, ((BinaryExpression)root).Right.StartPos?.Pos);
Assert.Equal(2, ((BinaryExpression)root).Right.StartPos?.Line);
Assert.Equal(1, ((BinaryExpression)root).Right.StartPos?.Column);
Assert.Equal(3, ((BinaryExpression)root).Right.Length);
```

IPositionAware\<T\>インターフェースでは以下のメソッドが定義されています。

- `T SetPos(Position startPos, int length);`

Parser#Position() メソッドを呼び出すことで、SetPost() メソッドが呼び出されて、現在の位置をセットしてくれます。

```csharp
enum BinaryOperator
{
    Add,
    Subtract
}

class Node : IPositionAware<Node>
{
    public int Length { get; protected set; }
    public Position? StartPos { get; protected set; }

    public Node SetPos(Position startPos, int length)
    {
        Length = length;
        StartPos = startPos;
        return this;
    }
}

class Literal : Node, IPositionAware<Literal>
{
    public int Value { get; }

    public Literal(int value)
    {
        Value = value;
    }

    public static Literal Create(string value) => 
        new Literal(int.Parse(value));

    public new Literal SetPos(Position startPos, int length) => 
        (Literal) base.SetPos(startPos, length);
}

class BinaryExpression : Node, IPositionAware<BinaryExpression>
{
    public BinaryOperator Op { get; }
    public Node Left { get; }
    public Node Right { get; }

    public BinaryExpression(BinaryOperator op, Node left, Node right)
    {
        Op = op;
        Left = left;
        Right = right;
    }

    public static Node Create(BinaryOperator op, Node left, Node right) => 
        new BinaryExpression(op, left, right);

    public new BinaryExpression SetPos(Position startPos, int length) => 
        (BinaryExpression)base.SetPos(startPos, length);
}

class MyParserPos
{
    static readonly Parser<BinaryOperator> Add = Parse.Char('+').Token().Return(BinaryOperator.Add);
    static readonly Parser<BinaryOperator> Subtract = Parse.Char('-').Token().Return(BinaryOperator.Subtract);
    static readonly Parser<Node> Number = Parse.Number.Token().Select(Literal.Create).Positioned();

    public static readonly Parser<Node> Expr = Parse.ChainOperator(
        Add.Or(Subtract), Number, BinaryExpression.Create).Positioned();
}
```


以上です。

### 参考資料

- [sprache/Sprache: A tiny, friendly, C# parser construction library](https://github.com/sprache/Sprache)
- [Sprache Part 9: Positioned - Justin Pealing](https://justinpealing.me.uk/post/2020-05-23-sprache9-positioned/)
- Positioned()
    - [Sprache/src/Sprache/IPositionAware.cs -- IPositionAware](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/IPositionAware.cs#L8)
    - [Sprache/src/Sprache/Position.cs -- Position](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Position.cs#L9)
    - [Sprache/src/Sprache/Parse.Positioned.cs -- Positioned](https://github.com/sprache/Sprache/blob/9d1721bb0dea638e35b9bbb2334fea6f99bf778e/src/Sprache/Parse.Positioned.cs#L13)
