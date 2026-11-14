---
layout:        post
title:         "[C#] マルチスレッド処理：Parallel.For/ForEachで並列処理"
type:          How-To
description:   "C#のParallel.ForおよびParallel.ForEachを使って配列やリストの反復処理を複数CPUコアで並列実行し、大量データ処理を高速化する方法を解説します。"
tags:          [dotnet, csharp, parallel, multithreading]
status:        stable
stale_after:   2028-05-25T00:00:00Z
generated:
  by:          human:tex2e
  at:          2025-05-25T13:24:46Z
date:          2025-05-24
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

Parallel.For と Parallel.ForEach は、ループ処理を並列に実行することで処理速度の向上をする .NET の並列プログラミング機能の一つです。
Parallel.For と Parallel.ForEach は、CPUの複数コアを活用して繰り返し処理を同時に実行するため、大量のデータ処理や計算を効率化できます。

### Parallel.ForEach

Parallel.ForEachは配列やリストなどのEnumerableを並列でループするときに使用します。
Parallel.ForEachで並列処理をするときは以下のように実装します。

```cs
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

class Program
{
    static void Main(string[] args)
    {
        var numbers = Enumerable.Range(0, 10);
        Parallel.ForEach(numbers, i =>
        {
            Console.WriteLine($"parallel.foreach count={i}");
        });
    }
}
```

もちろん、スレッドの競合や例外処理など、並列実行特有の注意点には気をつけて実装する必要があります。

### Parallel.For

単純な数字のインクリメントだけであれば、Parallel.Forを使って並列処理ができます。
Parallel.Forで以下のように並列処理すると、0〜9の値で繰り返し処理が並列起動で走ります。

```cs
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

class Program
{
    static void Main(string[] args)
    {
        Parallel.For(0, 10, i =>
        {
            Console.WriteLine($"parallel.for count={i}");
        });
    }
}
```

以上です。
