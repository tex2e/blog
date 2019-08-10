---
layout:        post
title:         "平方剰余とルジャンドル記号とヤコビ記号"
menutitle:     "平方剰余とルジャンドル記号とヤコビ記号"
date:          2019-08-09
tags:          Crypto
category:      Crypto
author:        tex2e
cover:         /assets/cover4.jpg
redirect_from:
comments:      true
published:     true
---

### 平方剰余

以下の合同式が解 $x$ を持つとき、整数 $a$ は法 n の**平方剰余** (quadratic residues; QR) といいます。

$$
x^2 \equiv a \pmod{n}
$$

平方剰余であれば True を返す関数を $\mathrm{QR}(a,n)$、非平方剰余であれば True を返す関数を $\mathrm{QNR}(a,n)$ と書くことにします。
さらに、$p$ が奇素数のとき、**オイラーの規定** (Euler's criterion) を使うことで、平方剰余の判定ができます。

$$
\bigg(\frac{a}{p}\bigg) \equiv a^{(p-1)/2} \pmod{p}
$$

Pythonで平方剰余を求めるプログラムを書くと以下のようになります（ただし、$q$ が奇素数であることが前提です）。

```python
def QR(a, p):
    return pow(a, (p - 1) // 2, p) == 1
```

### ルジャンドル記号

ルジャンドル記号 (Legendre symbol) は2つの整数 $a, p$ を引数にとる関数で、$(\frac{a}{p})$ と書きます。
この関数は、$a \ge 0$ が奇素数 $p$ を法として平方剰余であれば $1$、そうでなければ $-1$、$a$ が $p$ で割り切れる場合は $0$ を返します。

$$
\left(\frac{a}{p}\right) =
\begin{cases}
\phantom{-}0 & \text{if} \; \mathrm{gcd}(a,p) \ne 1 \\
\phantom{-}1 & \text{if} \; \mathrm{QR}(a,p) \\
          -1 & \text{if} \; \mathrm{QNR}(a,p)
\end{cases}
$$

先程定義した QR 関数も使って、Pythonでルジャンドル記号を計算するプログラムを書くと以下のようになります。

```python
import math

def QR(a, p):
    return pow(a, (p - 1) // 2, p) == 1

def legendre_symbol(a, p):
    if math.gcd(a, p) != 1:
        return 0
    if QR(a, p):
        return 1
    else:
        return -1
```

### ヤコビ記号

ルジャンドル記号では関数の2番目の引数 $p$ が奇素数のときだけしか使えませんでした。
この奇素数 $p$ を奇数の範囲まで拡張したものがヤコビ記号です。

ヤコビ記号 (Jacobi symbol) は2つの整数 $a, n$ を引数にとる関数で、ルジャンドル記号と同じように $(\frac{a}{n})$ と書きます。
$a$ と $n$ が互いに素で、$n = p_1 p_2 p_3 \cdots p_k$ と因数分解できるとき、次のように書きます。ただし、左辺は奇数 $n$ でヤコビ記号、右辺は奇素数 $p$ でルジャンドル記号であることに注意してください。

$$
\bigg(\frac{a}{n}\bigg) =
\bigg(\frac{a}{p_{1}}\bigg)
\bigg(\frac{a}{p_{2}}\bigg)
\bigg(\frac{a}{p_{3}}\bigg)
\; \cdots \;
\bigg(\frac{a}{p_{k}}\bigg)
$$

Pythonでヤコビ記号を計算するプログラムは以下のようになります (Sympyには以下のように書かれています [^sympy_legendre_symbol])。

```python
import math

def jacobi_symbol(a, n):
    if n < 0 or not n % 2:
        raise ValueError("n should be an odd positive integer")
    if a < 0 or a > n:
        a = a % n
    if n == 1 or a == 1:
        return 1
    if math.gcd(a, n) != 1:
        return 0

    j = 1
    if a < 0:
        a = -a
        if n % 4 == 3:
            j = -j
    while a != 0:
        while a % 2 == 0 and a > 0:
            a >>= 1
            if n % 8 in (3, 5):
                j = -j
        a, n = n, a
        if a % 4 == 3 and n % 4 == 3:
            j = -j
        a %= n
    if n != 1:
        j = 0
    return j
```

ヤコビ記号はルジャンドル記号を掛け合わせたものなので、$1$, $-1$, $0$ のいずれかの値が返ります。
プログラムでは答えを格納する変数を `j` として、$-1$ を掛け算する場合の時だけ、符号を入れ替える処理 `j = -j` をしています。

このヤコビ記号を求めるためには、いくつかのヤコビ記号に関する定理が使われています[^yale_edu]。

- 定理 1.1

    $$
    \bigg(\frac{0}{n}\bigg) =
    \begin{cases}
      1 & \text{if} \; n = 1 \\
      0 & \text{if} \; n > 1
    \end{cases}
    $$

- 定理 1.2

    $$
    \bigg(\frac{2}{n}\bigg) =
    \begin{cases}
      \phantom{-}1 & \text{if} \; n \equiv \pm 1 \pmod{8} \\
                -1 & \text{if} \; n \equiv \pm 3 \pmod{8}
    \end{cases}
    $$

- 定理 1.3

    $$
    \bigg(\frac{a}{n}\bigg) = \bigg(\frac{b}{n}\bigg)
    \;\;\; \text{if} \; a \equiv b \pmod{n}
    $$

- 定理 1.4

    $$
    \bigg(\frac{ab}{n}\bigg) =
    \bigg(\frac{a}{n}\bigg) \cdot \bigg(\frac{b}{n}\bigg)
    $$

- 定理 1.5

    (**平方剰余の相互法則**) 奇数 $a$ のとき、

    $$
    \bigg(\frac{a}{n}\bigg) =
    \begin{cases}
      -\bigg(\dfrac{n}{a}\bigg) & \text{if} \; a \equiv n \equiv 3 \pmod{4} \\
      \phantom{-}\bigg(\dfrac{n}{a}\bigg) & \text{if} \; \text{otherwise}
    \end{cases}
    $$




---

[^sympy_legendre_symbol]: [Number Theory &#8212; SymPy 1.4 documentation : legendre_symbol(a, p)](https://docs.sympy.org/latest/modules/ntheory.html#sympy.ntheory.residue_ntheory.legendre_symbol)
[^yale_edu]: [M. J. Fischer: The Legendre and Jacobi Symbols. 2010](http://zoo.cs.yale.edu/classes/cs467/2010s/handouts/ho07.pdf)
