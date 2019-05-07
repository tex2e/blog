---
layout:        post
title:         "平方剰余問題とオイラーの規準"
menutitle:     "平方剰余問題とオイラーの規準"
date:          2019-02-21
tags:          Crypto
category:      Crypto
author:        tex2e
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
---

数論において、下の合同式が解 $x$ をもつならば、整数 $a$ は法 $n$ の**平方剰余**（quadratic residues; QR）と定義されます[^QR]。
また、$x \not\equiv 0 \pmod{n}$ かつ整数 $q$ が平方剰余ではない場合は**平方非剰余**（quadratic nonresidue）と定義されます。

$$
x^2 \equiv a \pmod{n}
$$

例えば $a=4, n=5$ のときの平方剰余問題を満たす整数 $x$ は $x = 3$ と求まります。
答えが必ずある訳ではないので $a=3, n=5$ のときの平方剰余問題を満たす整数 $x$ はありません。

次に **平方剰余問題**とは、上の式において $a$ は $n$ を法とする平方剰余かどうか（上式を満たす整数 $x$ は存在するか）を調べる判別問題です。
これはオイラーの規準（Euler's criterion）を使うことで、簡単に平方剰余の判定ができるようになります[^Euler_criterion]。

- **オイラーの規準**

    $p$ を奇素数とすると、
    合同式 $x^2 \equiv a \pmod{p}$ の整数 $a$ が $p$ を法とする平方剰余であるときの必要十分条件は次の式で表される。

    $$
    a^{\frac{p-1}{2}} \equiv 1 \pmod{p}
    \tag{1}\label{1}
    $$

$p$ が奇素数（$p > 2$ の素数）であるとき、$x$ を求めるプログラムを Python で実装すると2行で書けます。

```python
def quadratic_residue(a, p):
    return pow(a, (p - 1) // 2, p) == 1
```

例えば素数 $p = 11$ とする有限体 $F_p$ について、$a = 0,1,...,10$ で平方剰余かを判定してみます。

```python
p = 11
for a in range(p):
    print('QR(%d, 11)? = %s' % (a, quadratic_residue(a, p)))
```

結果は次の通りです（追加で右側には、平方剰余を満たす場合の式を示しています）。

```
QR(0, 11)? = False
QR(1, 11)? = True      ... 1^2 ≡ 1 (mod 11)
QR(2, 11)? = False
QR(3, 11)? = True      ... 5^2 ≡ 3 (mod 11)
QR(4, 11)? = True      ... 2^2 ≡ 4 (mod 11)
QR(5, 11)? = True      ... 4^2 ≡ 5 (mod 11)
QR(6, 11)? = False
QR(7, 11)? = False
QR(8, 11)? = False
QR(9, 11)? = True      ... 3^2 ≡ 9 (mod 11)
QR(10, 11)? = False
```


[^QR]: [Quadratic residue -- Wikipedia](https://en.wikipedia.org/wiki/Quadratic_residue)
[^Euler_criterion]: [Euler's criterion -- Wikipedia](https://en.wikipedia.org/wiki/Euler%27s_criterion)
