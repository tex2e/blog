---
layout:        post
title:         "Map Filter Reduce in Perl6"
menutitle:     "Map Filter Reduce in Perl6"
date:          2017-03-06
tags:          Programming Language Perl6
category:      Perl6
author:        tex2e
cover:         /assets/cover1.jpg
redirect_from:
comments:      true
published:     true
---

関数型言語の三種の神器である Map, Filter, Reduce を Perl6 で行う方法。

Map: map
----------------

写像は map で行います。
map は関数なので、配列の値を直接操作することはしません。
もし破壊的な代入を望む場合は、map がミューテータとして振る舞うように `.` の代わりに `.=`
を使います。

```perl
my @array = [1, 22/7, 42, 3.14];

say @array.map({ $_ * 2 });  # => (2 6.285714 84 6.28)
say @array;                  # => [1 3.142857 42 3.14]

say @array.=map({ $_ * 2 }); # => [2 6.285714 84 6.28]
say @array;                  # => [2 6.285714 84 6.28]
```

map の引数は関数なので、次のように書いても写像をすることができます。

```perl
sub double($a) { $a * 2 }
say @array.map(&double);
say @array.map: { $_ * 2 }
say @array.map(-> $a { $a * 2 });
```

もしメソッドチェインが嫌いな場合は、次のような関数的な書き方もできます。

```perl
say map { $_ * 2 }, @array;
say map({ $_ * 2 }, @array);
```

### 補足

写像の本質からは離れてしまいますが、引数である関数の引数が2つ以上の場合でも動作します。

```perl
my @array = [1, 2, 3, 4];
say @array.map: { $^a + $^b }
# => (3 7)
```


Filter: grep
----------------

選択は grep で行います。
grep は関数なので、配列の値を直接操作することはしません。
もし破壊的な代入を望む場合は、grep がミューテータとして振る舞うように `.` の代わりに `.=`
を使います。

```perl
my @array = [1, 22/7, 42, 3.14];

say @array.grep({ $_ > 5 });  # => (42)
say @array;                   # => [1 3.142857 42 3.14]

say @array.=grep({ $_ > 5 }); # => [42]
say @array;                   # => [42]
```

grep の引数は関数なので、次のように書いても選択をすることができます。

```perl
sub filter($a) { $a > 5 }
say @array.grep(&filter);
say @array.grep: { $_ > 5 }
say @array.grep(-> $a { $a > 5 });
say @array.grep: -> $a { $a > 5 }
```

もしメソッドチェインが嫌いな場合は、次のような関数的な書き方もできます。

```perl
say grep { $_ > 5 }, @array;
say grep({ $_ > 5 }, @array);
```


Reduce: reduce
----------------

畳み込みは reduce で行います。

```perl
my @array = [1, 2, 3, 4];
say @array.reduce({ $^a + $^b });  # => 10
```

reduce の引数は関数なので、次のように書いても畳み込みをすることができます。

```perl
sub plus($a, $b) { $a + $b };
say @array.reduce(&plus);
say @array.reduce: { $^a + $^b }
say @array.reduce(-> $a, $b { $a + $b });
say @array.reduce(&[+]);
```

もしメソッドチェインが嫌いな場合は、次のような関数的な書き方もできます。

```perl
say reduce &[+], @array;  # => 10
say reduce(&[+], @array); # => 10
```

[Reduction Operators](https://docs.perl6.org/language/operators#Reduction_Operators)
を使うことによって、もっとスマートに畳み込むことができます。

```perl
say [+] @array;  # => 10

sub plus($a, $b) { $a + $b };
say [[&plus]] @array;  # => 10
```
